From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Subject: RE: [PATCH net-next 1/3] net: add IPv4 routing FIB support for swdev
Date: Tue, 6 Jan 2015 18:08:10 -0800
Message-ID: <98433f41e1876041471cdb513ca53fe5@mail.gmail.com>
References: <1420169361-31767-2-git-send-email-sfeldma@gmail.com>
	 <1420552709.32369.50.camel@stressinduktion.org>	 <CAE4R7bCOnYL1bat39UivcyAG-S1hx-EJpwC_hWNv8prjZqV3fg@mail.gmail.com>
 <1420574353.15181.19.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	john fastabend <john.fastabend@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:36180 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933151AbbAGCIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 21:08:11 -0500
Received: by mail-wg0-f42.google.com with SMTP id k14so346697wgh.29
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 18:08:10 -0800 (PST)
In-Reply-To: <1420574353.15181.19.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>For the first idea, I'll try to make an example:
>
>Initial setup:
># ip rule ls
>0:	from all lookup local
>32766:	from all lookup main
>32767:	from all lookup default
>
># ip rule add pref 100 iif swdev0 table 5 # ip rule ls
>0:	from all lookup local
>100:	from all iif swdev0 [detached] lookup 5
>> maybe we can show which rules are being able to get offloaded here
>32766:	from all lookup main
>32767:	from all lookup default
>
>table 5 should be the table we can insert routes into which are offloaded
>to
>hardware.
>
>During table modifications we linearly scan the rules if we find selectors
>which
>cannot be represented by hardware.
>
>In case we have a iif selector, we simply can use this table and just
>synthesize it
>into the particular interface.
>
>A ip-rule-from would need all the hardware being capable of matching source
>addresses, otherwise we cannot offload all routing tables with higher
>preference,
>same for a to/tos rule. If we encounter a fwmark rule, we certainly cannot
>represent it in hardware, so skip it (here we can think about entangling
>those with
>ACLs, but it feels hard to do).
>
>If rules are inserted or changed we must again validate the complete list
>of rules
>and decide if we need to flush all the routes and install a slow path via
>kernel.
>
>What do you think? Does that make sense? I could try to come up with an API
>for
>that. ;)
>

This sounds really good, but I suspect the real problem is the case where
the rule evaluation is in the hardware path right. If it is purely IF based
there is no issue .. but any other policy like missed in table 1, then use
table 2 will not work with this model .. or did I miss something ?
