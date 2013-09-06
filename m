From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: IPsec+SCTP+IPv6 bug (was: Re:
 https://bugzilla.kernel.org/show_bug.cgi?id=24412)
Date: Fri, 6 Sep 2013 19:56:10 +0300
Message-ID: <20130906165609.GA2795@p183.telecom.by>
References: <5229B37A.2070900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:65176 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086Ab3IFQ4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 12:56:14 -0400
Received: by mail-ea0-f178.google.com with SMTP id a15so1747923eae.9
        for <netdev@vger.kernel.org>; Fri, 06 Sep 2013 09:56:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5229B37A.2070900@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	[add netdev@ to CC]





My notes and recollections are below.

Bug reporter says traffic is unecnrypted which is technically a different thing,
but when I tried to reproduce absense of encryption, I couldn't even get past
established TCP connection.

IPv6 case works (worked) without IPsec (setkey -F; setkey -FP).
IPv4 case worked with IPsec.
IPv6 didn't work with IPsec.

setkey(8) setup:

	#!/usr/sbin/setkey -f
	flush;
	spdflush;
	add A B ah 0x42 -A hmac-sha256 0xKEY1;
	add B A ah 0x43 -A hmac-sha256 0xKEY2;
	add A B esp 0x44 -E blowfish-cbc 0xKEY3;
	add B A esp 0x45 -E blowfish-cbc 0xKEY4;
	spdadd A B any -P in ipsec esp/transport//require ah/transport//require;
	spdadd B A any -P in ipsec esp/transport//require ah/transport//require;

A, B -- IPv4 or IPv6 client/server addresses.
Client and server copy of the file should have matching keys and SPI numbers,
but "opposite" addresses (A <=> B).

Keys are written in hex.
IIRC setkey is picky about key lengths (they have to match exactly those of crypto algorithms).

--------------------------------------------------------------------

IPv4 reproducer:
	socat sctp-listen:3333 -
	echo plaintext | socat - sctp-connect:IP4IP4IP4IP4:3333

IPv6 reproducer:
	socat sctp6-listen:3333 -

#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <string.h>

int main(void)
{
        struct sockaddr_in6 sa6 = {};
        int fd;

        fd = socket(PF_INET6, SOCK_STREAM, 0x84);
        sa6.sin6_family = AF_INET6;
        sa6.sin6_port = htons(3333);
        inet_pton(AF_INET6, "IP6IP6IP6IP6IP6IP6", &sa6.sin6_addr);
        sa6.sin6_scope_id = 2;	/* it depends */
        connect(fd, (struct sockaddr *)&sa6, sizeof(struct sockaddr_in6));
        write(fd, "plaintext\n", strlen("plaintext\n"));
        close(fd);
        return 0;
}
