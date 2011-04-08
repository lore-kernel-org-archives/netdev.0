From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: extending feature word.
Date: Fri, 8 Apr 2011 11:17:41 -0700
Message-ID: <BANLkTik4+P3GU+NzZ6JkKPgXhwip-+PM5w@mail.gmail.com>
References: <BANLkTin52LqjxtVT+_y+gGam-QxeLq_iOA@mail.gmail.com>
	<20110408100535.GB10565@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:44738 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757479Ab1DHSRq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 14:17:46 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p38IHjxQ018583
	for <netdev@vger.kernel.org>; Fri, 8 Apr 2011 11:17:45 -0700
Received: from bwz5 (bwz5.prod.google.com [10.188.26.5])
	by kpbe17.cbf.corp.google.com with ESMTP id p38IHghj008155
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 8 Apr 2011 11:17:43 -0700
Received: by bwz5 with SMTP id 5so4741368bwz.34
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2011 11:17:41 -0700 (PDT)
In-Reply-To: <20110408100535.GB10565@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 8, 2011 at 3:05 AM, Micha=B3 Miros=B3aw <mirq-linux@rere.qm=
qm.pl> wrote:
> On Fri, Apr 01, 2011 at 07:07:05PM -0700, Mahesh Bandewar wrote:
>> Thanks for your comments on my loop-back patch. I was looking at the
>> code today from the perspective of extending various "features" for
>> word to an array of words and as Michael has pointed out, it's a hug=
e
>> change. So I'm thinking on the following lines
>> (include/linux/netdevice.h)
>>
>> +#define DEV_FEATURE_WORDS =A0 =A0 =A02
>> +#define LEGACY_FEATURE_WORD =A0 =A00
>> =A0 =A0 =A0 =A0/* currently active device features */
>> - =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 features;
>> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 features[D=
EV_FEATURE_WORDS];
>> =A0 =A0 =A0 =A0/* user-changeable features */
>> - =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw_feature=
s;
>> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw_feature=
s[DEV_FEATURE_WORDS];
>> =A0 =A0 =A0 =A0/* user-requested features */
>> - =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wanted_fea=
tures;
>> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wanted_fea=
tures[DEV_FEATURE_WORDS];
>> =A0 =A0 =A0 =A0/* VLAN feature mask */
>> - =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_featu=
res;
>> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_featu=
res[DEV_FEATURE_WORDS];
>
> Hmm. There might be no point in making features field an array.
> This gives us nothing really. Maybe just add features_2 or similar?
> If we ever get to the point there need to be more than two words for
> features we can think of some abstraction layer then.
>
That is right! making it an array doesn't really buy us anything
unless there is a uniform way of managing all the bits spread across
multiple words inside that array. This was the reason why I have
changed that array into a bitmap in the patch that I have posted
earlier. This way the upper limit (currently only 32 bits) will be
removed and we'll have a long term solution. There will be little bit
of work involved but 'doing-things-right' has cost associated.

> Or we might add a new field and put there NETIF_F_LLTX, NETIF_F_HIGHD=
MA
> and others that are not user changeable ever. Those don't need dynami=
c
> propagation to slave devices (e.g. VLAN) and wanted/hw_features for t=
hem.
>
This will certainly buy us some time but will be a temporary fix until
we runout of bits again. Also adding a second word (separate from the
first word) will create fragmentation and different approaches to
manage these two words and (I think) wont be desirable.

There will be another approach where we change this to u64 and
postpone the problem little longer and probably wait for u128 to make
it even longer. This is again a mid-term fix and not really a
solution.

In the patch that I have posted, I have changed these fiels to bitmaps
and a plan to take it there. This will _solve_ the problem once and
for all.


Thanks,
--mahesh..

> Best Regards,
> Micha=B3 Miros=B3aw
>
