From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6.23+] ingress classify to [nf]mark
Date: Wed, 16 Jan 2008 07:45:09 -0500
Message-ID: <1200487509.4457.33.camel@localhost>
References: <47866C69.3080904@bspu.unibel.by>
	 <1200001167.4443.38.camel@localhost>  <4787A663.4030204@bspu.unibel.by>
	 <1200063541.4483.42.camel@localhost>  <4787D49E.6080906@bspu.unibel.by>
	 <1200107027.4477.36.camel@localhost>  <4788FF45.702@bspu.unibel.by>
	 <1200253484.4427.33.camel@localhost>  <478B8250.90602@bspu.unibel.by>
	 <1200315372.4427.75.camel@localhost>  <478BE021.1070408@bspu.unibel.by>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mahatma@eu.by
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:2948 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363AbYAPMpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 07:45:13 -0500
Received: by py-out-1112.google.com with SMTP id u52so367172pyb.10
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 04:45:12 -0800 (PST)
In-Reply-To: <478BE021.1070408@bspu.unibel.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-14-01 at 20:20 -0200, Dzianis Kahanovich wrote:
> jamal wrote:
[..] 

> > Did that make sense?
>
> After current "#endif" - may be.

I am afraid that would be counter to expected behavior. 
Default is meant to apply when no value has been defined. Mark of 0 for
example doesnt mean "default". Let me demonstrate with the ifdefs again
with some arbitrary example:

-----------------
#ifdef CONFIG_NET_CLS_ACT
..classify ...
    .. action 1 sets mark to 0x11111
    .. action 2 checks some state and conditionally let action 3 execute
    .. action 3 sets mark to 0

if OK is returned set tc_index based on classid

#else // no actions compiled
..classify
.... jamal suggests: set default mark and tc_index for ingress here
#endif

// mahatma wants to set default for mark and tcindex here 
// so it works for both actions and none-action code
------------------------

Lets look at the case of actions compiled in:
I have defined my policies (in user space) so that the mark can be set
to either 0 or 0x1111 depending on some runtime state. 
Your default (kernel) code is now going to overide my policy - which is
bad. Even in the case of OK being returned, it is wrong to set tc_index;
unfortunately, we dont have an action that can set tc_index today; if we
did, we would need to remove that setting.

You other intent was to set the value of mark based on the value of
classid. You _can do that today already_ with no changes via a policy in
user space. You suggested to do an ifdef so you wont have to type in the
line which says how to mark, and i said that was a bad idea (we need
less ifdefs not more). 

For the case of no actions compiled in:
nothing can write into the values of either tcindex or mark after
classification (on ingress), so it is ok to override. If you did this
for egress as well, that would be wrong because it is expected that some
qdiscs may set or utilize these metadatum.

I am not sure if it made more sense this time?

> What "result" are with:
> 1) no filters?
> 2) 1 filter only, with "action continue"?

Please refer to above verbosity and see if it all makes better sense.

cheers,
jamal

