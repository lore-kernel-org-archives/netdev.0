From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: [3.15-rc3] Bisected: xen-netback mangles packets between two guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY instead of copy" series.
Date: Wed, 30 Apr 2014 12:45:06 +0200
Message-ID: <395225650.20140430124506@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:56913 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932252AbaD3KpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 06:45:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Zoltan,

Your series "TX grant mapping with SKBTX_DEV_ZEROCOPY instead of copy", merged into mainline with merge commit 4caeccb4de76440e433a15009636e77d003eb3d6,
seem to introduce a subtle bug on network traffic between 2 guests on a bridge on the same host.
I have one guest running apache as webdav server with SSL and another guest that is using that is uploading large files to that webdav server.
Small requests (some get's and propfind's) seem to work ok, but when the bulk uploading begins it fails with:

Attempt 1 failed. SSLError: [Errno 1] _ssl.c:1415: error:140943FC:SSL routines:SSL3_READ_BYTES:sslv3 alert bad record mac
Attempt 2 failed. SSLError: [Errno 1] _ssl.c:1415: error:140943FC:SSL routines:SSL3_READ_BYTES:sslv3 alert bad record mac
Attempt 3 failed. SSLError: [Errno 1] _ssl.c:1415: error:140943FC:SSL routines:SSL3_READ_BYTES:sslv3 alert bad record mac
Attempt 4 failed. SSLError: [Errno 1] _ssl.c:1415: error:140943FC:SSL routines:SSL3_READ_BYTES:sslv3 alert bad record mac

So some how large (probably fragmented) packets can get mangled when from guest to guest on the same host.
I don't see this with clients that upload large files from external sources.
Probably if SSL wasn't complaining it would probably be unnoticed for longer and doing some silent corruption.

I first blamed openssl, since it started around all the latest openssl mayhem and updates, but it turns out it is all xen-netback related again.

Since these commits break bisectabillity:
    - 1bb332af4cd889e4b64dacbf4a793ceb3a70445d  (note in commit message && kernel panic)
    - 62bad3199a4c20505fc36c169deef20b25e17c5f  (kernel panic)
i stopped bisecting at this point.

The upside is .. it's 100% reproduceable :-)

On a sidenote:
    Although DaveM seems to prefer patches, it would probably be nice to have larger patchsets like this one in a git tree somewhere,
    for more easy isolated applying to stable kernels, that would improve testing and bisecting things.
    For example the kernel xen.git tree makes it very easy to pull the devel branches to current stable .. 
    and even test those *isolated* and *before* the merge window, that greatly reduces the effort of testing and if anything is wrong .. in bisecting things.

    Another point would be: what *correctness* testing is actually done on the xen-net* patches ?
    As i suspect this is again about fragmented packets .. that doesn't seem to be included in any test case while it actually seems to be a case which is hard to get right...

--
Sander

The bisection log:
git bisect start
# bad: [cd6362befe4cc7bf589a5236d2a780af2d47bcc9] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
git bisect bad cd6362befe4cc7bf589a5236d2a780af2d47bcc9
# good: [df69491b7d1550137507a7eb5f2fc5dce0c1e534] Merge branch 'xen-netback'
git bisect good df69491b7d1550137507a7eb5f2fc5dce0c1e534
# good: [c12e69c6aaf785fd307d05cb6f36ca0e7577ead7] Merge tag 'staging-3.15-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging
git bisect good c12e69c6aaf785fd307d05cb6f36ca0e7577ead7
# bad: [49c0ca17ee8dd3530f688052d4eb2ae6d3e55119] Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next into for-davem
git bisect bad 49c0ca17ee8dd3530f688052d4eb2ae6d3e55119
# good: [370c5acef0326db3e8c10d42b941289c9c887a4a] Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next
git bisect good 370c5acef0326db3e8c10d42b941289c9c887a4a
# good: [ec5709403e6893acb4f7ca40514ebd29c3116836] net/mlx4_en: Use union for BlueFlame WQE
git bisect good ec5709403e6893acb4f7ca40514ebd29c3116836
# bad: [69bfb110fd58185df99a7dbe92a14c0d7ada764f] i40e: cleanup strings
git bisect bad 69bfb110fd58185df99a7dbe92a14c0d7ada764f
# bad: [aeb12c5ef7cb08d879af22fc0a56cab9e70689ea] gianfar: Separate out the Tx interrupt handling (Tx NAPI)
git bisect bad aeb12c5ef7cb08d879af22fc0a56cab9e70689ea
# bad: [389400428953bb002b173fa07d16d7a6f120843f] Merge tag 'rxrpc-devel-20140304' of git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs
git bisect bad 389400428953bb002b173fa07d16d7a6f120843f
# good: [5a8a1ab74dce1b50fe27745df477c502aec987eb] be2net: do external loopback test only when it is requested
git bisect good 5a8a1ab74dce1b50fe27745df477c502aec987eb
# skip: [1bb332af4cd889e4b64dacbf4a793ceb3a70445d] xen-netback: Add stat counters for zerocopy
git bisect skip 1bb332af4cd889e4b64dacbf4a793ceb3a70445d
# skip: [e86800f9201d35b6b2aac1583a9bf9e3a0b0c70d] Merge branch '6lowpan'
git bisect skip e86800f9201d35b6b2aac1583a9bf9e3a0b0c70d
# good: [31c70d5956fc3d1abf83e9ab5e1d8237dea59498] l2tp: keep original skb ownership
git bisect good 31c70d5956fc3d1abf83e9ab5e1d8237dea59498
