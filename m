From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Mon, 23 Oct 2006 18:41:27 -0400
Message-ID: <43e72e890610231541k2e8e6dcbq98f58a77aa8a52d7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:53117 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1752052AbWJWWl3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 18:41:29 -0400
Received: by wr-out-0506.google.com with SMTP id i7so392457wra
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2006 15:41:28 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches extend 802.11 regulatory domain support of the
d80211 wireless stack through two modules:

1. ieee80211_regdomains
2. iso3166-1

These modules provide an interface for management of regulatory
domains. Stack support has not been completed as it requires changes
which should be discussed here first. The hopes of extending
regulatory domains is so we have a consistant method by which all
drivers access valid channels and power restrictions which strictly
adhere to local regulatory domain constraints. Additionally if
in-kernel support of regulatory domains suffices for regulatory
agencies this should clear vendors from supporting FOSS wireless
drivers as this is the most common excuse not to so.

---

Details:


1. ieee80211_regdomains

Breaks down regulatory domains into data structures which allow
drivers to share channel and power contraints based on stack
regulatory domain. This driver adds in-kernel support for common
regulatory domains (such as FCC and ETSI), makes updating the
regulatory domain database through userspace completely optional which
should make it easier to introduce, and adds support for PtMP (Point
to MultiPoint) and PtP (Point to Point) type restrictions.

2. iso3166-1

ISO 3166-1, as part of the ISO 3166 standard, provides codes for the names
of countries and dependent areas. It was first published in 1974 by
the International Organization for Standardization (ISO) and defines three
different codes for each area:

    * ISO 3166-1 alpha-2, a two-letter system with many applications,
      most notably the Internet top-level domains (ccTLD) for countries.
    * ISO 3166-1 alpha-3, a three-letter system.
    * ISO 3166-1 numeric, a three-digit numerical system, which is
    identical to that defined by the United Nations Statistical Division.

Although this would usually be only used in userspace IEEE-802.11d
has made use of ISO-3166-1 alpha 3. This mapping was added
to enhance stack support for IEEE-802.11d and 802.11 Regulatory
Domain control. ieee80211_regdomains makes use of this module
by creating a map of iso3166 alpha3 country code to stack
regulatory domain.

--

Things which need review:

Current regulatory domain support is provided statically in
ieee80211_ioctl.c through ieee80211_regdom module parameter. This is
used to mask channels for scanning through ieee80211_init_client(),
which gets called during ieee80211_update_hw() which itself gets
called in ieee80211_register_hw(). Note that d80211.h also introduces
an unsigned int regulatory_domain in ieee80211_conf struct, this
however is never used even by current drivers or stack code.

The current setup on d80211.h makes regulatory domains device
specific. I believe this should be changed to be stack-specific --
that is, all drivers adhere to the restrictions set by the stack's
current regulatory domain. To enforce this though we'd need some
central stack-specific structure with stack-speficic settings. Are
there other parameters which can be stack-specific and configurable
which can be used to introduce a new structure which defines how the
stack behaves at a certain point in time? Should we take this approach
ieee80211_ioctl.c can then just query the stack regulatory domain
instead of a module_param.

Comments and patches are more than welcomed. Certain regulatory
domains are still being ironed out.

  Luis
