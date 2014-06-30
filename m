From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: IPsec policy database customization proposal
Date: Mon, 30 Jun 2014 14:50:18 +0200
Message-ID: <CADdy8Hq=Pi2PwuA4JLhd2smV7FKSwFLGCDvbCpviSqxhFaKTfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:53401 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbaF3MuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 08:50:19 -0400
Received: by mail-ie0-f169.google.com with SMTP id at1so6950502iec.28
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 05:50:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi IPsec and network maintainers,

After proposing a patchset to netdev (xfrm: scalability enhancements
for policy database) and discussing with Steffen Klassert, we agree on
the fact that the SPD lookup algorithm needs performance and
scalability improvements: SPs with non-prefixed selectors are
optimized through a hash table, but other SPs (the majority) are
stored in a sorted chained list, which does not scale. Additionally a
flowcache is used, and is known not to scale.

The bottleneck is the SPD lookup by selector (configuration and lookup itself).

Unfortunately, there is no all-in-one multi-field classifier that
would behave well in all situations. However, various classifiers
exist that are fitted to this or that use case. Therefore, I suggest
the following approach: adding hooks in the IPsec SPD, so that one can
dynamically register a custom SPD implementation ("SPD driver") fitted
to its use case, typically by loading a kernel module.

This obviously needs discussion before starting any development, so
here is a more detailed proposal:

- Define the minimum handlers to manipulate the SPD lookup by selector (alloc,
  insert, delete, flush, lookup_bysel, lookup_byflow, destroy...).
- export a register/unregister function, so that an SPD implementation may
  register/unregister its handlers.
- Separate the SPD common code from the SPD lookup by selector code. Keep the
  policy_all and policy_byidx tables in the common code, extract the current
  policy_inexact + policy_bydst implementation as an SPD driver. It is the
  default implementation when no SPD driver is registered.
- *struct xfrm_policy* must offer a private area for SPD driver data (void * or
  opaque place holder of fixed size or opaque place holder of size specific to
  driver implementation).
- since we keep the current implementation as the default, the policy_inexact +
  policy_bydst database heads (currently stored in netns->xfrm and xfrm_policy
  link fields (bydst and flo) may remain at their current location.
- SPD drivers needing some configuration may export their specific
  configuration API (/proc, netlink...)
- as a first step, we only support one registered handler at a time.
- as a first step, an SPD driver can only be loaded or unloaded if the SPD is
  empty (return EBUSY otherwise).

Remarks:

- this architecture is open to later evolutions such as supporting the
  registration of several handlers, dynamically listing/selecting/switching
  drivers via netlink messages (to support dynamic change of SPD implementation
  according to SPD content).
- loading/unloading or changing SPD drivers with a non empty SPD implies to
  rebuild the SPD from the SP list. This may lock the SPD for a rather long
  time.

I would like your opinion/questions/advices.

Best Regards,
Christophe
