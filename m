From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Mon, 4 Nov 2013 09:47:35 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73D7@saturn3.aculab.com>
References: <201310300525.r9U5Pdqo014902@ib.usersys.redhat.com> <20131030110214.GA10220@localhost.localdomain> <52710B09.6090302@redhat.com> <20131031183003.GC25894@hmsreliant.think-freely.org> <1383320566.1737.0.camel@bwh-desktop.uk.level5networks.com> <20131101160802.GB8467@hmsreliant.think-freely.org> <AE90C24D6B3A694183C094C60CF0A2F6026B73D3@saturn3.aculab.com> <20131101173701.GC8467@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"Doug Ledford" <dledford@redhat.com>,
	"Ingo Molnar" <mingo@kernel.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45238 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750773Ab3KDJu5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 04:50:57 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21865-09 for <netdev@vger.kernel.org>;
 Mon,  4 Nov 2013 09:50:56 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131101173701.GC8467@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I think you need 3 instructions, move a 0, conditionally move a 1
> > then add. I suspect it won't be a win!

Or, with an appropriately unrolled loop, for each word:
	zero %eax, cmove a 1 to %al
	cmove a 1 to %ah
	shift %eax left, cmove a 1 to %al
	cmove a 1 to %ah, add %eax onto somewhere.
However the 2nd instruction stream would have to use a different
register (IIRC 8bit updates depend on the entire register).

> I agree, that sounds interesting, but very cpu dependent.  Thanks for the
> suggestion, Ben, but I think it would be better if we just did the prefetch here
> and re-addressed this area when AVX (or addcx/addox) instructions were available
> for testing on hardware.

I didn't look too closely at the original figures.
With a simple loop you need 4 instructions per iteration (load, adc, inc, branch).
How close to one iteration per clock do you get?
I thought x86 hardware prefetch would load the cache lines for sequential
accesses - so any prefetch instructions are rather pointless.
However reading the value in the previous loop iteration should help.

I've just realised that there is a problem with the loop termination
condition also needing the flags register:-(
I don't remember the 'loop' instruction ever being added to any of the
fast path instruction decodes - so it won't help.

So I suspect the best you'll get is an interleaved sequence of load and adc
with an lea and inc (both to adjust the index) and a bne back to the top.
(the lea wants to be in the middle somewhere).
That might manage 1 clock per word + 1 clock per loop iteration (if the inc
and bne can be 'fused').

	David
