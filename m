From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 0/9] net: Refactor ip_route_input_slow
Date: Tue, 22 Sep 2015 22:51:27 -0700
Message-ID: <56023DDF.8000707@gmail.com>
References: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35961 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbbIWFv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 01:51:28 -0400
Received: by pacbt3 with SMTP id bt3so12377754pac.3
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 22:51:28 -0700 (PDT)
In-Reply-To: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2015 03:55 PM, David Ahern wrote:
> ip_route_input_slow is a maze of gotos (9 of them!) making it error
> prone and difficult to read. This patchset refactors it, removing all
> but 2 of the labels. The brd_input label for broadcast path requires
> too many inputs to make a reasonble helper out of it so I left it as is.
>
> None of these patches change functionality, only move code around
> to make ip_route_input_slow more readable.
>
> Size comparison using gcc version 4.7.2 (Debian 4.7.2-5)
>
> With CONFIG_IP_ROUTE_VERBOSE:
>      Before patches:
>      $ size kbuild2/net/ipv4/route.o
>         text	   data	    bss	    dec	    hex	filename
>        20615	   2321	     32	  22968	   59b8	kbuild2/net/ipv4/route.o
>
>      After patches:
>      $ size kbuild/net/ipv4/route.o
>         text	   data	    bss	    dec	    hex	filename
>        20774	   2321	     32	  23127	   5a57	kbuild/net/ipv4/route.o
>
> An increase of 159 bytes with CONFIG_IP_ROUTE_VERBOSE.
>
> Without CONFIG_IP_ROUTE_VERBOSE:
>      Before patches:
>      $ size kbuild2/net/ipv4/route.o
>         text	   data	    bss	    dec	    hex	filename
>        19778	   2321	     32	  22131	   5673	kbuild2/net/ipv4/route.o
>
>      After patches:
>      $ size kbuild/net/ipv4/route.o
>         text	   data	    bss	    dec	    hex	filename
>        19858	   2321	     32	  22211	   56c3	kbuild/net/ipv4/route.o
>
> An increase of 80 bytes without CONFIG_IP_ROUTE_VERBOSE.
>
> David Ahern (9):
>    net: Remove martian_source_keep_err goto label
>    net: Remove e_inval label from ip_route_input_slow
>    net: Remove e_nobufs label from ip_route_input_slow
>    net: Move rth handling from ip_route_input_slow to helper
>    net: Move martian_destination to helper
>    net: Remove martian_source goto
>    net: Remove martian_destination label
>    net: Remove local_input label
>    net: Remove no_route label
>
>   net/ipv4/route.c | 239 ++++++++++++++++++++++++++++++++-----------------------
>   1 file changed, 139 insertions(+), 100 deletions(-)
>

One option you might consider when untangling this is to just return the 
values instead of leaving any labels.  I just did a quick test on my 
system with gcc version 5.1.1 and going through and just replacing all 
of the labels with returns actually resulted in smaller code since the 
compiler was smart enough to just combine the returns anyway.

You may also want to increase the scope of this patch set to include 
__mkroute_input as it ends up being compiled into this function as 
well.  From what I have seen there is a bit of redundancy with some of 
the code from local_input.

- Alex
