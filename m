From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: TCP NewReno and single retransmit
Date: Mon, 27 Oct 2014 16:49:33 -0200
Message-ID: <544E93BD.50202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47016 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751877AbaJ0Stf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 14:49:35 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s9RInZ1E019785
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 14:49:35 -0400
Received: from localhost.localdomain (ovpn-113-123.phx2.redhat.com [10.3.113.123])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s9RInXle025665
	for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 14:49:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We have a report from a customer saying that on a very calm connection, like 
having only a single data packet within some minutes, if this packet gets to 
be re-transmitted, retrans_stamp is only cleared when the next acked packet is 
received. But this may make we abort the connection too soon if this next 
packet also gets lost, because the reference for the initial loss is still for 
a big while ago..

                    local-machine              remote-machine
                         |                           |
          send#1---->(*1)|--------> data#1 --------->|
                   |     |                           |
                  RTO    :                           :
                   |     |                           |
                  ---(*2)|----> data#1(retrans) ---->|
                   | (*3)|<---------- ACK <----------|
                   |     |                           |
                   |     :                           :
                   |     :                           :
                   |     :                           :
                 16 minutes (or more)                :
                   |     :                           :
                   |     :                           :
                   |     :                           :
                   |     |                           |
          send#2---->(*4)|--------> data#2 --------->|
                   |     |                           |
                  RTO    :                           :
                   |     |                           |
                  ---(*5)|----> data#2(retrans) ---->|
                   |     |                           |
                   |     |                           |
                 RTO*2   :                           :
                   |     |                           |
                   |     |                           |
       ETIMEDOUT<----(*6)|                           |
    (diagram is not mine)

ETIMEDOUT happens way too early, because that's based on (*2) stamp.

Question is, can't we really clear retrans_stamp on step (*3)? Like with:

@@ -2382,31 +2382,32 @@ static inline bool tcp_may_undo(const struct tcp_sock *tp)
  static bool tcp_try_undo_recovery(struct sock *sk)
  {
         struct tcp_sock *tp = tcp_sk(sk);

         if (tcp_may_undo(tp)) {
                 int mib_idx;

                 /* Happy end! We did not retransmit anything
                  * or our original transmission succeeded.
                  */
                 DBGUNDO(sk, inet_csk(sk)->icsk_ca_state == TCP_CA_Loss ? 
"loss" : "retrans");
                 tcp_undo_cwnd_reduction(sk, false);
                 if (inet_csk(sk)->icsk_ca_state == TCP_CA_Loss)
                         mib_idx = LINUX_MIB_TCPLOSSUNDO;
                 else
                         mib_idx = LINUX_MIB_TCPFULLUNDO;

                 NET_INC_STATS_BH(sock_net(sk), mib_idx);
         }
         if (tp->snd_una == tp->high_seq && tcp_is_reno(tp)) {
                 /* Hold old state until something *above* high_seq
                  * is ACKed. For Reno it is MUST to prevent false
                  * fast retransmits (RFC2582). SACK TCP is safe. */
                 tcp_moderate_cwnd(tp);
+               tp->retrans_stamp = 0;
                 return true;
         }
         tcp_set_ca_state(sk, TCP_CA_Open);
         return false;
  }

We would still hold state, at least part of it.. WDYT?

Thanks,
Marcelo
