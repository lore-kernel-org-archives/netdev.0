From: "Tom Lendacky" <toml@us.ibm.com>
Subject: IPSec: IPv6 random failures
Date: Thu, 22 May 2003 13:15:58 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF5D0301D4.91C949F2-ON86256D2E.0061C9C3-86256D2E.006456C0@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Every now and then I see some failures in the TAHI tests that I am running
on IPv6.  The scenario has to do with two tunnel SP entries and the
corresponding SA entries on a system and sending an echo reply to each
(unique) destination in each SP.  The first echo reply is successfully
processed, but the second one is not.  After looking further, it appears
that the following occurs:

- For the first echo reply, during the xfrm_lookup a flow lookup is
performed and a flow cache entry created.
- For the second echo reply (to a different destination than the first
one), during the xfrm_lookup a flow lookup is performed and matches the
previously created flow cache entry, even though it shouldn't.

It turns out that the flowi structure uses pointers to the IPv6 addresses
(whereas IPv4 uses the actual address) and that even though the actual
destination IPv6 addresses are different between the first and second echo
reply, the pointers are not (actually the pointers to both the source and
destination in6_addr structures are the same).  Since the pointers are the
same the flowi compare is successful and the cache entry is used, which,
for the second echo reply, does not point to the correct policy.

It would seem that the flowi structure should use the actual IPv6 addresses
instead of pointers to them, like the IPv4 section does.  Feedback?

Thanks,
Tom
