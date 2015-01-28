From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCHv3 ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Wed, 28 Jan 2015 12:34:29 +0800
Message-ID: <54C866D5.4070708@gmail.com>
References: <20150127.001226.711259930266409202.davem () davemloft ! net> <1422349230-17394-1-git-send-email-fan.du@intel.com> <063D6719AE5E284EB5DD2968C1650D6D1CAD3B2B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 'Fan Du' <fan.du@intel.com>,
	"steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:58081 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965308AbbA1Eig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 23:38:36 -0500
Received: by mail-pa0-f46.google.com with SMTP id lj1so22954682pab.5
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 20:38:36 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAD3B2B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B401=E6=9C=8827=E6=97=A5 17:46, David Laight =E5=86=
=99=E9=81=93:
> From: Fan Du
>> structure like xfrm_usersa_info or xfrm_userpolicy_info
>> has different sizeof when compiled as 32bits and 64bits
>> due to not appending pack attribute in their definition.
>
> Don't 'pack' the structure, just ensure that all the fields
> are fixed sized and on their natural boundary.

Is that simple??

The layout is exactly the same between 32bits and 64bits, only differen=
ce
is the last cache line padding, because even if last cache line is not =
fully
occupied, but at least use even bytes, not odd bytes. I think this rela=
tes
to cache HW behaviour, not how the structure is naturally aligned or no=
t.
Actually, the structure members is aligned indeed.

#### 64bits
struct xfrm_usersa_info {
     struct xfrm_selector       sel;                  /*     0    56 */
     struct xfrm_id             id;                   /*    56    24 */

     /* XXX last struct has 3 bytes of padding */

     /* --- cacheline 1 boundary (64 bytes) was 16 bytes ago --- */
     xfrm_address_t             saddr;                /*    80    16 */
     struct xfrm_lifetime_cfg   lft;                  /*    96    64 */
     /* --- cacheline 2 boundary (128 bytes) was 32 bytes ago --- */
     struct xfrm_lifetime_cur   curlft;               /*   160    32 */
     /* --- cacheline 3 boundary (192 bytes) --- */
     struct xfrm_stats          stats;                /*   192    12 */
     __u32                      seq;                  /*   204     4 */
     __u32                      reqid;                /*   208     4 */
     __u16                      family;               /*   212     2 */
     __u8                       mode;                 /*   214     1 */
     __u8                       replay_window;        /*   215     1 */
     __u8                       flags;                /*   216     1 */

     /* size: 224, cachelines: 4, members: 12 */
     /* padding: 7 */
     /* paddings: 1, sum paddings: 3 */
     /* last cacheline: 32 bytes */
};


#### 32bits
struct xfrm_usersa_info {
     struct xfrm_selector       sel;                  /*     0    56 */
     struct xfrm_id             id;                   /*    56    24 */

     /* XXX last struct has 3 bytes of padding */

     /* --- cacheline 1 boundary (64 bytes) was 16 bytes ago --- */
     xfrm_address_t             saddr;                /*    80    16 */
     struct xfrm_lifetime_cfg   lft;                  /*    96    64 */
     /* --- cacheline 2 boundary (128 bytes) was 32 bytes ago --- */
     struct xfrm_lifetime_cur   curlft;               /*   160    32 */
     /* --- cacheline 3 boundary (192 bytes) --- */
     struct xfrm_stats          stats;                /*   192    12 */
     __u32                      seq;                  /*   204     4 */
     __u32                      reqid;                /*   208     4 */
     __u16                      family;               /*   212     2 */
     __u8                       mode;                 /*   214     1 */
     __u8                       replay_window;        /*   215     1 */
     __u8                       flags;                /*   216     1 */

     /* size: 220, cachelines: 4, members: 12 */
     /* padding: 3 */
     /* paddings: 1, sum paddings: 3 */
     /* last cacheline: 28 bytes */
};

> Possibly add a compile-time check that the structure is
> of the expected size.
>
> 	David
>


--=20
No zuo no die but I have to try.
