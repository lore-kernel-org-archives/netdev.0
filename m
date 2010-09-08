From: Ingo Kofler <ikofler@edu.uni-klu.ac.at>
Subject: Problems obtaining software TX timestamps
Date: Wed, 08 Sep 2010 14:11:54 +0200
Message-ID: <4C877D8A.6040002@edu.uni-klu.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailsrv.uni-klu.ac.at ([143.205.180.44]:49171 "EHLO
	mailsrv.uni-klu.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753697Ab0IHMkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 08:40:45 -0400
Received: from mailsrv.uni-klu.ac.at (localhost [127.0.0.1])
	by mailsrv.uni-klu.ac.at (Postfix) with ESMTP id 6C72084302
	for <netdev@vger.kernel.org>; Wed,  8 Sep 2010 14:11:54 +0200 (CEST)
Received: from [143.205.122.142] (itec142.itec.uni-klu.ac.at [143.205.122.142])
	by mailsrv.uni-klu.ac.at (Postfix) with ESMTP id 574DF8406A
	for <netdev@vger.kernel.org>; Wed,  8 Sep 2010 14:11:54 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear all,

I am trying to obtain software TX timestamps for a each outgoing packet 
of an UDP socket. For that purpose I set the SO_TIMESTAMPING socket 
option to SOF_TIMESTAMPING_TX_SOFTWARE | SOF_TIMESTAMPING_SOFTWARE. The 
setsockopt call succeeds and also a subsequent getsockopt returns the 
correct flags. However, if a send a single datagram over the socket and 
try to fetch the packet as well as its timestamp via the socket's 
MSG_ERRQUEUE I do not get any information. Rather, the select call waits 
infinitely on the error queue....

I hardly found any documentation on this timestamping mechanism except 
the text file in the kernel source code. All I've figured out is that if 
I want to have hardware TX timestamps, I'll have to make a further ioctl 
which requires root permissions to active the hardware timestamping. But 
this is not what I want... software timestamps are sufficient for me. 
Here's my code....


int main (int argc, char **argv) {

    int rv;
    int sock;

    // allocate a socket
    printf("allocating socket\n");
    sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (sock==-1) return 1;

    // connect socket to IP + port passed via command line
    printf("connecting socket\n");
    struct sockaddr_in toAddr;
    memset(&toAddr, 0, sizeof(struct sockaddr_in));
    toAddr.sin_family = PF_INET;
    toAddr.sin_addr.s_addr = inet_addr(argv[1]);
    toAddr.sin_port = htons(atoi(argv[2]));
    rv = connect(sock, (struct sockaddr*) &toAddr, sizeof(struct 
sockaddr_in));
    if (rv!=0) return 1;

    // try to enable software TX timestamps
    printf("enabling (?) timestamping\n");
    int flags =  SOF_TIMESTAMPING_TX_SOFTWARE | SOF_TIMESTAMPING_SOFTWARE;
    rv = setsockopt(sock, SOL_SOCKET, SO_TIMESTAMPING, &flags, 
sizeof(flags));
    if (rv!=0) return 2;

    // check if the setsockopt was successful
    socklen_t slen = sizeof(flags);
    rv = getsockopt(sock, SOL_SOCKET, SO_TIMESTAMPING, &flags, &slen);
    if (rv!=0) return 3;
    printf("getsockopt returned %d\n", flags);
   
    // send something via the socket
    char buffer[200];
    int len = sizeof(buffer);
    rv = send(sock, buffer, len, 0);
    printf("send returned %d\n", rv);

    // prepare select call to wait for packet on MSG_ERRQUEUE
    fd_set errorfs;
    FD_ZERO(&errorfs);   
    FD_SET(sock, &errorfs);
    rv = select(sock + 1, 0, 0, &errorfs, NULL);                 <<--- 
This select blocks forever...
    printf("select returned %d\n", rv);
    ...

Any suggestions what's wrong with my code?  Btw. I've tested this with 
kernel 2.6.31 and 2.6.33...

Thanks and best regards,
Ingo
