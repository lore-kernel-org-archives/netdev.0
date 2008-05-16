From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Re: [PATCH] drivers/net: remove network drivers' last
 few uses of IRQF_SAMPLE_RANDOM
Date: Fri, 16 May 2008 12:19:49 +0200
Message-ID: <482D5FC5.2070103@firstfloor.org>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>	<20080515142154.0595e475@core>	<36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>	<20080515173939.1ec968be@core>	<482C7DA3.1090809@garzik.org>	<482C953A.4080205@garzik.org>	<87abirytxj.fsf@basil.nowhere.org> <20080516105635.6cb1f505@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Chris Peterson <cpeterso@cpeterso.com>,
	tpmdd-devel@lists.sourceforge.net, tpm@selhorst.net,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:45340 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402AbYEPKT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 06:19:57 -0400
In-Reply-To: <20080516105635.6cb1f505@core>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Cox wrote:
> On Fri, 16 May 2008 02:27:36 +0200
> Andi Kleen <andi@firstfloor.org> wrote:
> 
>> Jeff Garzik <jeff@garzik.org> writes:
>>> A hw_random driver for TPM still needs to (a) parse the TPM header for
>>> return code, (b) extract RNG bytes out at offset 14, and (c) figure
>>> out some way to get a tpm_chip pointer.
>> (d) auto feed the information into random.c. Otherwise it'll be useless
>> for most people.
> 
> No - you don't want to do FIPS randomness verification in kernel space.

Just think a little bit: system has no randomness source except the
hardware RNG. you do your strange randomness verification. if it fails
what do you do? You don't feed anything into your entropy pool and all
your  random output is predictable (just boot time)  If you add anything
predictable from another source it's still predictable, no difference.

Also in general what happens in the hypothetical
case that your random generator e.g. generates all zeros (which
is very unlikely but let's assume it): your entropy doesn't get
significantly worse than it was before. Previously it was just
seeded with the boot time (or other sources) and now you're adding some
zeroes. The output is still as random as the previous state.
While that changes the state of the entropy pool it doesn't make it any
easier to predict.

The only problem you got from possible bogus input is that the entropy
counts will be wrong, but in my experience nearly all programs
use /dev/urandom anyways because /dev/random is just a DoS waiting
to happen and user space programmers know that.

Basically with this insisting on FIPS you're violating the
strong variant of Steinbach's rule: not only "never test for an
error condition you don't know how to handle", but
"never test for an error condition you can't handle"

Also why do you not trust your random generator but trust
your CPU to correctly execute the cryptographic algorithm?
Not trusting your own hardware doesn't really make any sense here.

> Plus all the other random generator inputs are done via the user space
> daemon as they should be.

Yes and which makes them about useless because distros don't run that
daemon by default so users don't get the feature. Besides it's all not
needed anyways because the FIPS verification is pointless.

-Andi

