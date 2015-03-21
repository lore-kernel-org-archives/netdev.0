From: Joe Harvell <joe.harvell@tekcomms.com>
Subject: [PATCH] iproute2: fix broken get_prefix_1
Date: Sat, 21 Mar 2015 15:07:31 -0500
Message-ID: <550DCF83.6000403@tekcomms.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemming@brocade.com>,
	Vadim Kochan <vadim4j@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0119.outbound.protection.outlook.com ([207.46.100.119]:48195
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751642AbbCUUIp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2015 16:08:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes bug that causes a basic 'ip addr add' command to fail address due 
to the address prefix is incorrectly determined to be invalid.

I assume master must have some new change because this fix was needed 
for a basic 'ip addr add 10.0.3.1/24 dev dumbo label foo' command I 
pased in.  In this case, 'family' passed into get_addr_1 two lines above 
is zero, causing get_addr_1 to detect the family from the address and 
populate the result in the family field in dst.  But then instead of 
passing in the result, family (still 0) is passed in to af_bit_len. 
Without my change, the above command complains that 10.0.3.1/24 is not 
an address prefix.  With the change it works fine as expected.

The following changes since commit 4612d04d6b8f07274bd5d0688f717ccc189499ad:

   tc class: Show class names from file (2015-03-15 12:27:40 -0700)

are available in the git repository at:

   git@github.com:jharvell/iproute2.git fix-broken-get_prefix_1

for you to fetch changes up to d24d5cb9ad9b09ceb37aa8ffe8c1160c14f713ef:

   Signed-off-by: Joe Harvell <joe.harvell@tekcomms.com> (2015-03-21 
15:03:32 -0500)

----------------------------------------------------------------
Joe Harvell (2):
       Fixing obvious error of passing in the wrong variable for the 
family parameter     of af_bit_len.
       Signed-off-by: Joe Harvell <joe.harvell@tekcomms.com>

  lib/utils.c | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/utils.c b/lib/utils.c
index 9cda268..0d08a86 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -477,7 +477,7 @@ int get_prefix_1(inet_prefix *dst, char *arg, int 
family)

         err = get_addr_1(dst, arg, family);
         if (err == 0) {
-               dst->bitlen = af_bit_len(family);
+               dst->bitlen = af_bit_len(dst->family);

                 if (slash) {
                         if (get_netmask(&plen, slash+1, 0)
