From: "Ulrich Windl" <Ulrich.Windl@rz.uni-regensburg.de>
Subject: Q: (linux 3.0.101) SO_LINGER2 & FIN_WAIT2
Date: Fri, 12 Aug 2016 14:10:38 +0200
Message-ID: <57ADD8DE020000A1000223EB@gwsmtp1.uni-regensburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrzmta1.uni-regensburg.de ([194.94.155.51]:56940 "EHLO
	rrzmta1.uni-regensburg.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbcHLMUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 08:20:18 -0400
Received: from rrzmta1.uni-regensburg.de (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id 5969158376
	for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 14:10:40 +0200 (CEST)
Received: from gwsmtp1.uni-regensburg.de (gwsmtp1.uni-regensburg.de [132.199.5.51])
	by rrzmta1.uni-regensburg.de (Postfix) with ESMTP id 2303C582A5
	for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 14:10:39 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Please excuse me for asking this question, but I'm fighting a problem I don't understand:
I have written an application that forwards data from on TCPv4 stream to another, that is, you start the utility on hostA listening at the IP of hostA, portA, redirecting to hostB, portB. Now when hostC connects to hostA:portA vir portC, the traffic is forwarded to hostB:portB, and hostB's replies are forwarded back to hostC:portC.

That works well enough (I tested with Firefox on hostC and a webserver on hostB). I only have a problem: From time to time a shutdown(sock, 1) of the socket connected to hostB:portB seems to hand forever after hostC has closed or shutdown it socket.

The effect is that connections stay in CLOSE_WAIT like this:
# netstat -tn |grep 48123
tcp        1      0 172.20.17.252:64236     172.20.17.78:48123      CLOSE_WAIT
tcp        1      0 172.20.17.252:54347     172.20.17.78:48123      CLOSE_WAIT
tcp        1      0 172.20.17.252:51009     172.20.17.78:48123      CLOSE_WAIT
tcp        1      0 172.20.17.252:49899     172.20.17.78:48123      CLOSE_WAIT

Even though I set SO_LINGER option, the shutdown never completes, and I'll have to kill the process handling the connection.
I've read about SO_LINGER2, but being confused by the description I tried to read the source code. I don't understand (/usr/src/linux/net/ipv4/tcp.c, tcp_close()) the case when tp->linger2 >= 0: The value of tp->linger2 is not used anywhere; instead tcp_fin_time(sk) is used.

The doc (man 7 tcp) says:
       TCP_LINGER2 (since Linux 2.4)
              The  lifetime  of orphaned FIN_WAIT2 state sockets.  This option
              can be used to override the  system-wide  setting  in  the  file
              /proc/sys/net/ipv4/tcp_fin_timeout for this socket.  This is not(...)

Can somebody clarify?

Back to my application: I handle each direction (HostC->HostA->HostB (read), HostB->HostA->HostC (write)) in a separate thread, and I try to shutdown() the corresponding socket direction if I detect an EOF condition in any direction. typically read first. Occasionally I see an error "Transport
 endpoint is not connected" when shutting down the write connection on the socket connected to HostA. Is there a mistake on my side?

(D)[16049](172.20.16.36/13939): handler uses input socket 4
(D)[16049](172.20.16.36/13939): set SO_LINGER on socket 4 to 1, 0
(D)[16049](172.20.16.36/13939): connection_handler: use output socket 0
(D)[16049](172.20.16.36/13939): set SO_LINGER on socket 0 to 1, 0
(D)[16049](172.20.16.36/13939): connection_handler: connected to 172.20.17.78/48123 in 99 microseconds
(D)[16049](172.20.16.36/13939): create input thread
(D)[16049](172.20.16.36/13939): create output thread
(D)[16049](input): received 147 bytes from 4
(D)[16049](input): sent 147 bytes to 0
(D)[16049](output): received 671 bytes from 0
(D)[16049](output): sent 671 bytes to 4
(D)[16049](input): copy 4 (172.20.16.36/13939) -> 0 (172.20.17.78/48123) finished with 0
(D)[16049](input): shutdown read direction (4 -> 0)
(D)[16049](input): shutdown socket 4 with 0
(D)[16049](input): shutdown socket 0 with 1
(D)[16049](172.20.16.36/13939): input thread 140526054442752 returned 0
(D)[16049](172.20.16.36/13939): wait for output thread 140526062835456
(D)[16049](output): copy 0 (172.20.17.78/48123) -> 4 (172.20.16.36/13939) finished with 0
(D)[16049](output): shutdown write direction (0 -> 4)
(D)[16049](output): shutdown socket 0 with 0
(N)[16049](output): failed to shutdown socket 0 with 0: Transport endpoint is not connected
(D)[16049](output): shutdown socket 4 with 1
(W)[16049](172.20.16.36/13939): output thread 140526062835456 returned -1
(D)[16049](172.20.16.36/13939): close inbound socket 4
(D)[16049](172.20.16.36/13939): close outbound socket 0
(D)[16049](172.20.16.36/13939): connection_handler finished
(D)[16049](172.20.16.36/13939): handler exiting after 17.038

Here are some code sketches (the whole thing is quite long and verbose) for both threads:

/* handle input data */
static  void    *input_thread(void *arg)
{
        handler_t       *handler = arg;
        char            ID[ID_MAX];
        tsap_t          *const i_conn = &handler->i_conn;
        tsap_t          *const o_conn = &handler->o_conn;
        thread_result_t result;
        int             i;

/*...*/
        result.i = socket_copy(i_conn->sock, o_conn->sock, &handler->i_bytes,
                               &handler->last_rd, ID);
        vlogf(LOG_DEBUG,
              "%s: copy %d (%s) -> %d (%s) finished with %d",
              ID, i_conn->sock, i_conn->r_addr.desc_real, o_conn->sock,
              o_conn->r_addr.desc_real, result.i);
        vlogf(LOG_DEBUG, "%s: shutdown read direction (%d -> %d)", ID,
              i_conn->sock, o_conn->sock);
        if ( do_shutdown(ID, i_conn->sock, SHUT_RD) != 0 )
                result.i = -1;
        if ( do_shutdown(ID, o_conn->sock, SHUT_WR) != 0 )
                result.i = -1;
        return(result.ptr);
}

/* handle output data */
static  void    *output_thread(void *arg)
{
        handler_t       *handler = arg;
        char            ID[ID_MAX];
        tsap_t          *const i_conn = &handler->i_conn;
        tsap_t          *const o_conn = &handler->o_conn;
        thread_result_t result;
        int             i;

	/*...*/
        result.i = socket_copy(o_conn->sock, i_conn->sock, &handler->o_bytes,
                               &handler->last_wr, ID);
        vlogf(LOG_DEBUG,
              "%s: copy %d (%s) -> %d (%s) finished with %d",
              ID, o_conn->sock, o_conn->r_addr.desc_real, i_conn->sock,
              i_conn->r_addr.desc_real, result.i);
        vlogf(LOG_DEBUG, "%s: shutdown write direction (%d -> %d)", ID,
              o_conn->sock, i_conn->sock);
        if ( do_shutdown(ID, o_conn->sock, SHUT_RD) != 0 )
                result.i = -1;
        if ( do_shutdown(ID, i_conn->sock, SHUT_WR) != 0 )
                result.i = -1;
        return(result.ptr);
}

The connection_handler process does this roughly (after having set up the sockets):
...
                if ( (err = pthread_create(&handler->input, NULL, input_thread,
                                           handler)) != 0 )
                {
                        result = -1;
                }
                vlogf(LOG_DEBUG, "%s: create output thread", handler->ID);
                if ( (err = pthread_create(&handler->output, NULL,
                                           output_thread, handler)) != 0 )
                {
                        result = -1;
                }
...
                if ( (err = pthread_join(handler->input, &ret.ptr)) == 0 )
                {
...
                }
	if ( (err = pthread_join(handler->output, &ret.ptr)) == 0 \
)
                {
...
	}
...
                if ( do_close(i_conn->sock) != 0 )
                        result = -1;
                if ( do_close(o_conn->sock) != 0 )
                        result = -1;

Regards,
Ulrich
