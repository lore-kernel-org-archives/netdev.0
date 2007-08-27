From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Mon, 27 Aug 2007 14:09:10 -0700
Message-ID: <20070827140910.31f5c074@freepuppy.rosehill.hemminger.net>
References: <1187808408.4314.15.camel@johannes.berg>
	<1188086976.18004.5.camel@localhost>
	<1188212049.6756.18.camel@johannes.berg>
	<20070827.134131.41639376.davem@davemloft.net>
	<1188248263.18004.131.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48009 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751692AbXH0VKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 17:10:45 -0400
In-Reply-To: <1188248263.18004.131.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 27 Aug 2007 13:57:42 -0700
Joe Perches <joe@perches.com> wrote:

> On Mon, 2007-08-27 at 13:41 -0700, David Miller wrote:
> > From: Johannes Berg <johannes@sipsolutions.net>
> > Date: Mon, 27 Aug 2007 12:54:09 +0200
> > > #define MAC_FMT "%s"
> > > #define MAC_ARG(a) ({char __buf[18]; print_mac(a, __buf); __buf;})
> 
> > I don't think this works.
> 
> $ cat test_fmt.c
> #include <stdio.h>
> #include <stdlib.h>
> 
> #define MAC_FMT "%s"
> #define MAC_ARG(a) ({char __buf[18]; print_mac(a, __buf); __buf;})
> 
> int print_mac(const char* p, char* b)
> {
>   return sprintf(b, "%02x:%02x:%02x:%02x:%02x:%02x",
> 		 p[0], p[1], p[2], p[3], p[4], p[5]);
> }
> 
> int main(int argc, char** argv)
> {
>   char m1[6] = {1,2,3,4,5,6};
>   char m2[6] = {6,5,4,3,2,1};
> 
>   printf("m1: " MAC_FMT " m2: " MAC_FMT "\n", MAC_ARG(m1), MAC_ARG(m2));
>   return 0;
> }
> 
> $ gcc test_fmt.c
> $ ./a.out
> m1: 01:02:03:04:05:06 m2: 06:05:04:03:02:01

As Dave said, you are passing out a variable which is no longer valid outside
of it's scope. GCC today may accidentally allow it or it might work, but it
is only because of a GCC bug. If I recall discussions about some of the
recent kernel space bloat, GCC doesn't reuse space for variables declared
in subblocks.

I.e:
int foo(int x) {
	if (x) {
	    char block1[1024];
		...
	} else {
	    char block2[128];
	}

}

Compiler should be able to use same stack space for block1/block2 and only grow
stack by 1K. But it probably isn't that smart.




-- 
Stephen Hemminger <shemminger@linux-foundation.org>
