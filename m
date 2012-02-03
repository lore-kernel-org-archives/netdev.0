From: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Subject: Connect hangs for a while before returns -1 with ECONNREFUSED on
 3.2 for loopback
Date: Fri, 03 Feb 2012 10:25:53 +0400
Message-ID: <4F2B7DF1.5050303@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080308080300040602080203"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([213.33.243.219]:52718 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753826Ab2BCGez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 01:34:55 -0500
Received: from [192.168.38.62] (este.oktetlabs.ru [192.168.38.62])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(No client certificate requested)
	by shelob.oktetlabs.ru (Postfix) with ESMTPSA id 77E8D7F619
	for <netdev@vger.kernel.org>; Fri,  3 Feb 2012 10:25:52 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080308080300040602080203
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On kernel 3.2.0-0.bpo.1-amd64 I see some strange behaviour of connect() 
in case of connection via loopback. Lets see the following steps (there 
are two processes on the host, and the first one with two threads)

Thread1:
1. socket(PF_INET, SOCK_STREAM, 0) ->  3
2. bind(10.27.10.1:26820) ->  0 /* The address is bound to some interface, eth1 */
3. listen(3, 1) ->  0

sleep for a while

Thread2:
4. shutdown(3, SHUT_RD) ->  0

sleep for a while

Another process:
5. socket(PF_INET, SOCK_STREAM, 0) ->  4
6. connect(4, 10.27.10.1:26820)

connect() returns -1 with ECONNREFUSED but after some time. In case of 
two peer hosts connect() returns -1 with ECONNREFUSED almost 
immediately, so does for the other kernel versions.

In attachment c program to reproduce this problem.

--------------080308080300040602080203
Content-Type: text/x-csrc;
 name="connect_loopback.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="connect_loopback.c"

#include <unistd.h>
#include <stdio.h>
#include <netinet/in.h>
#include <errno.h>

main()
{
    int child_sock;
    int sock;
    struct sockaddr_in addr;
    int rc;
    int proc;

    sock = socket(PF_INET, SOCK_STREAM, 0);
    printf("socket() -> %d(%d)\n", sock, errno);

    addr.sin_family = AF_INET;
    addr.sin_port = htons(12345);
    addr.sin_addr.s_addr = inet_addr("10.0.1.1");
    rc = bind(sock, (struct sockaddr *)&addr, sizeof(addr));
    printf("bind() -> %d(%d)\n", rc, errno);

    rc = listen(sock, 1);
    printf("listen() -> %d(%d)\n", rc, errno);

    sleep(1);

    rc = shutdown(sock, SHUT_RD);
    printf("shutdown() -> %d(%d)\n", rc, errno);

    proc = fork();
    if (proc)
    {
        child_sock = socket(PF_INET, SOCK_STREAM, 0);
        printf("Child: socket() -> %d(%d)\n", child_sock, errno);
        rc = connect(child_sock, (struct sockaddr *)&addr, sizeof(addr));
        printf("connect() -> %d(%d)\n", rc, errno);
    }
    else
    {
        printf("Waiting...\n");getchar();
    }

    return 0;
}

--------------080308080300040602080203--
