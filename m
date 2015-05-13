From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink & rhashtable status
Date: Tue, 12 May 2015 23:15:40 -0700
Message-ID: <1431497740.566.129.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431495036.566.126.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150513054037.GA26595@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:34002 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbbEMGPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 02:15:43 -0400
Received: by iecmd7 with SMTP id md7so23004571iec.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 23:15:42 -0700 (PDT)
In-Reply-To: <20150513054037.GA26595@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-13 at 13:40 +0800, Herbert Xu wrote:
> On Tue, May 12, 2015 at 10:30:36PM -0700, Eric Dumazet wrote:
> > 
> > linux-3.17, 3.18, 3.19 and 4.0.2 have issues with netlink/rhashtable,
> > making things like getaddrinfo() not working after a while :
> 
> Do you use namespaces?
> 
> Cheers,

No.

Trick is to start about 200 threads using getaddrinfo()

This was spotted using netperf, but you probably can use something like
this program.

Thanks.



#include <netdb.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

struct addrinfo *resolve_host(const char *hostname, const char *port,
                              int family)
{
  struct addrinfo hints;
  struct addrinfo *ai;
  int count;
  int error;

  memset(&hints, 0, sizeof(hints));
  hints.ai_family = family;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_protocol = IPPROTO_TCP;
  hints.ai_flags = AI_CANONNAME | AI_ADDRCONFIG;
  count = 0;
  do {
    error = getaddrinfo(hostname, port, &hints, &ai);
    count += 1;
    if (error == EAI_AGAIN) {
      sleep(1);
    }
  } while ((error == EAI_AGAIN) && (count <= 5));

  if (error) {
    printf("error\n");
    return (NULL);
  }

  return (ai);
}

int main(int argc, char **argv)
{
  const char host[] = "127.0.0.1";
  const char *port = NULL;
  const int family = 0;
  unsigned long iterations, i;

  if (argc != 2) {
    printf("Expected one arg.\n");
    return -1;
  }
  iterations = atol(argv[1]);
  for (i = 0; i < iterations; ++i) {
    resolve_host(host, port, family);
  }
  return 0;
}
