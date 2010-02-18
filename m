From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: connect() sometimes succeeds when it shouldn't
Date: Fri, 19 Feb 2010 01:09:09 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1002190053260.16302@melkinpaasi.cs.helsinki.fi>
References: <201002181947.11125.bruce@cran.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bruce Cran <bruce@cran.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45199 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113Ab0BRXJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 18:09:12 -0500
In-Reply-To: <201002181947.11125.bruce@cran.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Feb 2010, Bruce Cran wrote:

> I've found that if I run a program that does lots of calls to connect() then 
> it will eventually succeed when there's no server listening. For SCTP it takes 
> a few thousand, for TCP up to a couple of million.  I first came across the 
> problem in Windows, where the connection was being processed so quickly that 
> by the time the handler function had finished, the 'connecting' flag had 
> already been reset, which wasn't expected. I've not checked the Linux sources 
> to see if something similar is happening though.
> 
> The machine I tested it on was running a 2.6.32 i686 kernel.
> 
> The test code can be found at 
> http://www.cran.org.uk/~brucec/linux/badconnect.c

Perhaps you just managed to dial your own number? ...Please try with 
my improved version of badconnect.c below. :-)

-- 
 i.

--
#include <sys/types.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <netinet/in.h>
#include <errno.h>

int main(void)
{
	struct sockaddr_in sa;
	int fd;

        fd = socket(AF_INET, SOCK_STREAM, 0);
	if (fd <= 0)
		err(1, "socket");
	memset(&sa, 0, sizeof(sa));
	sa.sin_addr.s_addr = INADDR_ANY;
	sa.sin_family = AF_INET;
	sa.sin_port = htons(60234);
	if (bind(fd, (struct sockaddr*)&sa, sizeof(sa))) {
		perror("bind");
		exit(1);
	}

	memset(&sa, 0, sizeof(sa));
	sa.sin_family = AF_INET;
	sa.sin_port = htons(60234);
	if (inet_aton("127.0.0.1", &(sa.sin_addr)) != 1)
		exit(1);

	if (connect(fd, (struct sockaddr*)&sa, sizeof(sa)) == 0) {
		printf("bad connect on iter %d\n", 1);
		exit(1);
	}

	close(fd);

	return 0;

}
