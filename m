From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Thu, 21 Nov 2013 11:07:27 +0100
Message-ID: <528DDB5F.8080400@6wind.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com> <1383725153-26298-1-git-send-email-christophe.gouault@6wind.com> <20131107112549.GP31491@secunet.com> <527B8DC5.6080702@6wind.com> <1902752B0C92F943AB7EA9EE13E2DEEC1273BA977C@HQ1-EXCH02.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Collins <bsderandrew@gmail.com>,
	Fan Du <fan.du@windriver.com>
To: Saurabh Mohan <saurabh.mohan@brocade.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f48.google.com ([209.85.214.48]:61479 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab3KUKIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 05:08:12 -0500
Received: by mail-bk0-f48.google.com with SMTP id v10so219725bkz.35
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 02:08:11 -0800 (PST)
In-Reply-To: <1902752B0C92F943AB7EA9EE13E2DEEC1273BA977C@HQ1-EXCH02.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Saurabh,

Good to read your rationale.

On 11/18/2013 10:38 PM, Saurabh Mohan wrote:
>
>
>> -----Original Message----- From: Christophe Gouault
>> [mailto:christophe.gouault@6wind.com] Sent: Thursday, November 07,
>> 2013 4:56 AM To: Steffen Klassert Cc: David S. Miller; Herbert Xu;
>> netdev@vger.kernel.org; Saurabh Mohan; Sergei Shtylyov; Eric
>> Dumazet Subject: Re: [PATCH net v3] vti: fix spd lookup: match
>> plaintext pkt, not ipsec pkt
>>
>> Hello Steffen,
>>
>> I am also interested in knowing Saurabh's intentions regarding the
>> behavior of policies bound to vti interfaces.
>>
> The semantics is to match the policy "src 0.0.0.0/0 dst 0.0.0.0/0
> proto any" That is the only policy that VTI should use. The mark is
> needed to distinguish and limit the policy to a specific vti tunnel
> interface only. There is no other policy that may be applied to a vti
> interface. The fact that traffic is going over the tunnel interface
> implies that it must be encrypted/decrypted. Applying the above
> policy is a way to achieve that.

The proposed patch respects this model and accepts the same
configuration, but extends the possibilities: you can still set the
policy "src 0.0.0.0/0 dst 0.0.0.0/0 proto any" (which is the typical use
case), the mark is still used to distinguish and limit the policy to a
specific vti tunnel interface only, the traffic that is going over the
tunnel interface still implies that it must be encrypted/decrypted (in
tunnel mode).

But you can optionally apply differentiated policies within the same
tunnel, by setting SPs with narrower selectors: according to the
plaintext traffic that crosses the tunnel, you can request to use
different protocols (esp/ah), different SAs, maybe drop some traffic.
Only ipsec tunnel mode and drop policies should be bound to a VTI interface.

And the patch restores the SP semantics: the selector is used to match
the plaintext traffic, not the IPsec encrypted traffic.

Best Regards,
Christophe

>> However, please note that setting a policy with a wildcard
>> selector works in both cases (before or after this patch), so a
>> common test case can be defined.
>>
>> Actually the *previous* patch on vti (7263a5187f9e vti: get rid of
>> nf mark rule in prerouting) introduced significant changes, and
>> implies behaviors dependant on the kernel version, but it seemed to
>> meet Saurabh's agreement, as the following thread witnesses:
>>
>> http://www.spinics.net/lists/netdev/msg253134.html
>>
> Getting rid of the pre-routing mark, which had to be done outside of
> the vti tunnel code was prone to misconfiguration. Though it is
> unfortunate that it creates a kernel version dependency.
