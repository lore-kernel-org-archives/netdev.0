From: Changli Gao <xiaosuo@gmail.com>
Subject: The errno when failing to connect to a unix stream socket due to timeout
Date: Mon, 30 Mar 2015 21:51:56 +0800
Message-ID: <CABa6K_Evv5+rXFvAOa0RGZ7Mbi11idS=0Xmyq=AURCcV7r6NJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:33992 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbbC3NwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 09:52:17 -0400
Received: by iedfl3 with SMTP id fl3so132970728ied.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 06:52:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear all,

When working with the unix stream socket, I find that when failing to
connect to a unix stream socket due to timeout, the errno is EAGAIN
instead of ETIMEDOUT. IMHO, EAGAIN should be for non blocking IO only,
but if we change the errno, there maybe a risk: breaking some
applications. So, I want to know your ideas. Correct me if I made any
mistake.

Here is the code snippet:

#include <unistd.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/un.h>

int main()
{
        int serv = socket(PF_UNIX, SOCK_STREAM, 0);
        struct sockaddr_un addr;

        remove("/tmp/test.unix");
        memset(&addr, 0, sizeof(addr));
        addr.sun_family = AF_UNIX;
        strcpy(addr.sun_path, "/tmp/test.unix");
        bind(serv, (struct sockaddr *)&addr, sizeof(addr));
        listen(serv, 1);

        int i;
        for (i = 0; i < 3; ++i) {
                int clnt = socket(PF_UNIX, SOCK_STREAM, 0);
                struct timeval tv;
                tv.tv_sec = 3;
                tv.tv_usec = 0;
                setsockopt(clnt, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof(tv));
                if (connect(clnt, (struct sockaddr *)&addr, sizeof(addr)))
                        perror("connect");
        }

        return 0;
}

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
