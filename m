From: Paul Wouters <pwouters@redhat.com>
Subject: Re: CCM/GCM implementation defect
Date: Thu, 23 Apr 2015 11:21:19 -0400
Message-ID: <55390DEF.2010904@redhat.com>
References: <20150423032619.GA17648@gondor.apana.org.au> <20150423114533.GI8928@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59338 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757828AbbDWPVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2015 11:21:21 -0400
In-Reply-To: <20150423114533.GI8928@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2015 07:45 AM, Steffen Klassert wrote:
> On Thu, Apr 23, 2015 at 11:26:20AM +0800, Herbert Xu wrote:
>> Hi:
>>
>> It looks like our IPsec implementations of CCM and GCM are buggy
>> in that they don't include the IV in the authentication calculation.
> 
> Seems like crypto_rfc4106_crypt() passes the associated data it
> got from ESP directly to gcm, without chaining with the IV.
> 
>>
>> This definitely breaks interoperability with anyone who implements
>> them correctly.  The fact that there have been no reports on this
>> probably means that nobody has run into this in the field yet.
>>
>> On the security side, this is probably not a big deal for CCM
>> because it always verifies the authentication tag after decryption.
>> But for GCM this may be a DoS issue as an attacker could modify
>> the IV without triggering the authentication check and thus cause
>> an unnecessary decryption.  For both CCM and GCM this will result
>> in random data injected as a packet into the network stack which
>> hopefully will be dropped.
>>
>> In order to fix this without breaking backwards compatibility,
>> my plan is to introduce new templates such as rfc4106v2 which
>> implement the RFC correctly.  The existing templates will be
>> retained so that current users aren't broken by the fix.
> 
> Adding a second template for the correct implementation is
> probaply the only thing that we can do if we don't want to
> break backwards compatibility. But maybe we can add a warning
> to the old implementation, such that users notice that they
> use a broken version.

Unless we have a cryptographer indicate to us how that this mistake does not significantly reduce or break the confidentiality and authentication, I do not
think we should keep a known broken implementation around. Lets say this brings GCM security down to ROT13, then it just needs to die without keeping
interoperability.

Additionally, looking at how long we suffered and still suffer from defaulting to something broken (sha2_256 truncation) I'm really not in favour of keeping
broken crypto implementations around.

Paul
