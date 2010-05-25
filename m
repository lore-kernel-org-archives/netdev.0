From: jamal <hadi@cyberus.ca>
Subject: Re: Question about an assignment in handle_ing()
Date: Tue, 25 May 2010 05:51:07 -0400
Message-ID: <1274781067.3878.872.camel@bigi>
References: <20100524112236.GF2810@psychotron.lab.eng.brq.redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.hengli.com.au, kaber@trash.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:46519 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab0EYJvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 05:51:10 -0400
Received: by qyk13 with SMTP id 13so6969427qyk.1
        for <netdev@vger.kernel.org>; Tue, 25 May 2010 02:51:09 -0700 (PDT)
In-Reply-To: <20100524112236.GF2810@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Mon, 2010-05-24 at 13:22 +0200, Jiri Pirko wrote:

> Question is if this code is correct here. Maybe I'm missing something but
> why is this dependent on a ptype was found previously?

The code is correct. 

Main reason for the else condn is driven by optimization:
If you are running tcpdump or other af packet type code, the "if" condn
is hit and matching actions are not allowed trample on that same packet
data. They have to make a private copy; otherwise, the "else" is hit and
(for optimization reason) you give ok to the actions that follow to
munge the packet. Essentially, you dont want actions to alloc/copy every
single time when you are not running tcpdump for example; reason is that
most of the time you run tcpdump it is for debugging.
[I had seen very observable differences on some old mips board back in
the day on whether you avoided copy every time vs when debugging by
running tcpdump and copied every packet.]

There is a secondary reason for the else stmnt: you want tcpdump to see
the naked packet as it came on say eth0. I am in travel mode at the
moment, so i cant validate this for you via a testcase (which moves the
else outside), but i know this was a problem back then...
Example. If i had a packet sequence path as follows: 
--> eth0-->tcpdump0-->filter match --> action: edit -->action: redirect
to dummy0-->tcpdump1-->dummy0(drop and count)
Then you want the packet on tcpdump0 to be whatever was seen by eth0.
You want to see on tcpdump1 whatever was seen by dummy0 - which is an
edited version of whatever was seen by eth0. 

If this description makes sense to you (and since this has come up more
than once before), would you be kind enough to submit a patch that fixes
the current comment and add my ACK to it?

cheers,
jamal

