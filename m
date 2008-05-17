From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Re: [PATCH] drivers/net: remove network drivers' last
 few uses of IRQF_SAMPLE_RANDOM
Date: Sat, 17 May 2008 12:59:52 +0200
Message-ID: <482EBAA8.3040506@firstfloor.org>
References: <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <20080515173939.1ec968be@core> <482C7DA3.1090809@garzik.org> <482C953A.4080205@garzik.org> <87abirytxj.fsf@basil.nowhere.org> <20080516105635.6cb1f505@core> <482D5FC5.2070103@firstfloor.org> <20080516121239.GA9627@gondor.apana.org.au> <482DB568.1040704@firstfloor.org> <20080517010136.GA15102@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Chris Peterson <cpeterso@cpeterso.com>,
	tpmdd-devel@lists.sourceforge.net, tpm@selhorst.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49875 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbYEQK77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 06:59:59 -0400
In-Reply-To: <20080517010136.GA15102@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, May 16, 2008 at 06:25:12PM +0200, Andi Kleen wrote:
>> You could do that, but what advantage would it have? I don't think it's
>> worth running the FIPS test, or rather requiring the user land daemon
>> and leaving behind most of the userbase just for this.
> 
> The obvious advantage is that you don't unblock /dev/random readers
> until there is real entropy available.

As far as I can figure out with some research (stracing, strings) pretty
much every interesting cryptographic software except gpg keygen uses
/dev/urandom anyways. They have to because too many systems don't have
enough entropy and /dev/random simply blocks far too often and does not
really work. When you check the now famous openssl source you see it
uses /dev/urandom first simply because of this problem.  They only
have /dev/random for systems where /dev/urandom is not available.

That is because the real world cryptographers care as much about DoS as
about other issues.

It's also quite understandable:
"Sorry our company couldn't receive email because nobody banged on the
keyboard of the mail server"
Clearly that would be absurd, but if e.g. openssl used /dev/random you
would easily get into that situation.

Part of the problem here is of course this strange insistence to not
auto-feed from all available random sources. If you set this entropy
standards too high soon none are left and the entropy pool
is often only very poorly fed. So by setting too high
standards you actually lower practical security.

> Remember that a hardware RNG failure is a catastrophic event, 

Is it? The pool is just as random as it was before because the hash
output will depend on all previous input.  So even if you e.g. add a
known string of zeroes for example it should be still as much or as
little unpredictible as it was before. The big difference is
that it is just cryptographic security instead of true entropy,
but without enough entropy (or you not trusting your entropy) there's no
choice.

Also my assumption is that if the hardware RNG fails the rest of
the system (CPU, memory) will likely fail with it. Well I admit
I'm not 100% sure about that, but the stories going around about
RNG failures are so vaguely folksy that my assumptions are likely
as good as anybody elses :)

> so a heavy-handed response such as blocking /dev/random is reasonable.

I only know of GPG initial key gen who really relies on it and I'm sure
I wasn't the only one to feel silly when  banging random keys on the
keyboard while generating a key :)

Obviously that doesn't work for all the interesting cases like
session keys etc, or even ssh keygen so they don't use it for that. It's
pretty much unusable for all "invisible cryptography" where the user is
not (or only very vaguely) aware there is cryptography being used and
that is the far majority of cryptography. gpg can only get away with it
because they assume an educated user and even there it doesn't work
well.

I've been actually pondering a kind of compromise here:

Would people be ok with kernel auto-feeding for /dev/urandom only? I've
been pondering that and I think that would work just as well in practice
 given the facts above. Then you would still only get blocking
/dev/random with the user daemon, but that won't matter because all
the usual users don't rely on thatanyways.

The only open question is if the pools need to be duplicated or not for
this case.

-Andi

