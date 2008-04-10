From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 10371] New: On big-endian machines getsockopt
 returns 0 (via optval) for optlen==1 when returned value should 255
Date: Thu, 10 Apr 2008 01:31:55 -0700 (PDT)
Message-ID: <20080410.013155.26553899.davem@davemloft.net>
References: <bug-10371-10286@http.bugzilla.kernel.org/>
	<20080331113349.1c3abb48.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: M.Piechaczek@osmosys.tv, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52903
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752918AbYDJIb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 04:31:57 -0400
In-Reply-To: <20080331113349.1c3abb48.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 31 Mar 2008 11:33:49 -0700

> On Mon, 31 Mar 2008 08:16:05 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=10371
 ...
> You've done all the hard work - please email us a tested patch?

I've checked in the following fix for this bug, thanks!

commit 951e07c930f5f66b676eaa4c32a1b0d8e2d7d06a
Author: David S. Miller <davem@davemloft.net>
Date:   Thu Apr 10 01:29:36 2008 -0700

    [IPV4]: Fix byte value boundary check in do_ip_getsockopt().
    
    This fixes kernel bugzilla 10371.
    
    As reported by M.Piechaczek@osmosys.tv, if we try to grab a
    char sized socket option value, as in:
    
      unsigned char ttl = 255;
      socklen_t     len = sizeof(ttl);
      setsockopt(socket, IPPROTO_IP, IP_MULTICAST_TTL, &ttl, &len);
    
      getsockopt(socket, IPPROTO_IP, IP_MULTICAST_TTL, &ttl, &len);
    
    The ttl returned will be wrong on big-endian, and on both little-
    endian and big-endian the next three bytes in userspace are written
    with garbage.
    
    It's because of this test in do_ip_getsockopt():
    
    	if (len < sizeof(int) && len > 0 && val>=0 && val<255) {
    
    It should allow a 'val' of 255 to pass here, but it doesn't so it
    copies a full 'int' back to userspace.
    
    On little-endian that will write the correct value into the location
    but it spams on the next three bytes in userspace.  On big endian it
    writes the wrong value into the location and spams the next three
    bytes.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index f72457b..c2921d0 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1132,7 +1132,7 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	}
 	release_sock(sk);
 
-	if (len < sizeof(int) && len > 0 && val>=0 && val<255) {
+	if (len < sizeof(int) && len > 0 && val>=0 && val<=255) {
 		unsigned char ucval = (unsigned char)val;
 		len = 1;
 		if (put_user(len, optlen))
