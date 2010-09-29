From: Nick Bowler <nbowler@elliptictech.com>
Subject: Regression (ancient), bisected: TCP hangs with certain ESP6 SA.
Date: Wed, 29 Sep 2010 10:22:13 -0400
Message-ID: <20100929142213.GA26031@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since around 2.6.25, TCP connections hang when using IPv6 ESP, in
transport mode, with AES and a null MAC.  It really is that specific:
ICMP/UDP work fine with this cipher/mac combination, tunnel mode works
fine, and so do DES/triple-DES.

In this scenario, there are two hosts, host1 and host2, with IPv6
addresses fec0:42::2 and fec0:42::3, respectively.  Host2 is running
lighttpd serving a 300MB binary file called 'big'.

On host1, we run the following setkey script:

  add fec0:42::2 fec0:42::3 esp 0x6B8B4567  -f seq-pad
   -E rijndael-cbc 0x643C98696633487374B0DC5119495CFF
   -A null;
  
  add fec0:42::3 fec0:42::2 esp 0x327B23C6  -f seq-pad
   -E rijndael-cbc 0x3D1B58BA507ED7AB2EB141F241B71EFB
   -A null;
  
  spdadd fec0:42::2 fec0:42::3 any -P out ipsec
   esp/transport//require;
  spdadd fec0:42::3 fec0:42::2 any -P in ipsec
   esp/transport//require;

And on host2, the complementary script:

  add fec0:42::2 fec0:42::3 esp 0x6B8B4567  -f seq-pad
   -E rijndael-cbc 0x643C98696633487374B0DC5119495CFF
   -A null;
  
  add fec0:42::3 fec0:42::2 esp 0x327B23C6  -f seq-pad
   -E rijndael-cbc 0x3D1B58BA507ED7AB2EB141F241B71EFB
   -A null;
  
  spdadd fec0:42::3 fec0:42::2 any -P out ipsec
   esp/transport//require;
  spdadd fec0:42::2 fec0:42::3 any -P in ipsec
   esp/transport//require;

>From host1 we can now do ping6 fec0:42::3 and it will work.  However,
when we attempt to wget 'http://[fec0:42::3]/big',  we get the
following:

  Connecting to fec0:42::3:80... connected.
  HTTP request sent, awaiting response... Read error (connection timed
  out) in headers.
  Giving up.

A similar issue occurs with SSH: we can connect successfully, and even
run some commands on the remote host, but the connection stalls
permanently as soon as we try to do anything remotely interesting.

I managed to bisect the issue to the following commit.  Amazingly, the
commit can still be reverted with almost no hassle and solves this
particular issue.

b5c15fc004ac83b7ad280acbe0fd4bbed7e2c8d4 is the first bad commit
commit b5c15fc004ac83b7ad280acbe0fd4bbed7e2c8d4
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Thu Feb 14 23:49:37 2008 -0800

    [IPV6]: Fix reversed local_df test in ip6_fragment
    
    I managed to reverse the local_df test when forward-porting this
    patch so it actually makes things worse by never fragmenting at
    all.
    
    Thanks to David Stevens for testing and reporting this bug.
    
    Bill Fink pointed out that the local_df setting is also the wrong
    way around.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 e8b31c5a4196df9292237f6c654758eebeadf00d a6be8522530892360965c38951b45520bc49160b M	net

git bisect start
# good: [bbf25010f1a6b761914430f5fca081ec8c7accd1] Linux 2.6.23
git bisect good bbf25010f1a6b761914430f5fca081ec8c7accd1
# bad: [8e0ee43bc2c3e19db56a4adaa9a9b04ce885cd84] Linux 2.6.29
git bisect bad 8e0ee43bc2c3e19db56a4adaa9a9b04ce885cd84
# bad: [6b648063eb51e2620774ddaebef4e07f2f6f4ae7] [S390] Cleanup lcs printk messages.
git bisect bad 6b648063eb51e2620774ddaebef4e07f2f6f4ae7
# good: [2c044a4803804708984931bcbd03314732e995d5] USB: fix codingstyle issues in drivers/usb/core/*.c
git bisect good 2c044a4803804708984931bcbd03314732e995d5
# bad: [334d094504c2fe1c44211ecb49146ae6bca8c321] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.26
git bisect bad 334d094504c2fe1c44211ecb49146ae6bca8c321
# bad: [e51c683717e3ac21713444e9a517aa8e0ad0ee48] zd1211rw: Fixed incorrect constant name.
git bisect bad e51c683717e3ac21713444e9a517aa8e0ad0ee48
# good: [0afc2edfada50980bec999f94dcea26ebad3dda6] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
git bisect good 0afc2edfada50980bec999f94dcea26ebad3dda6
# good: [b791dd3ed7bef989f268365e85800862e8ac756f] Merge branch 'upstream-davem' of master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6
git bisect good b791dd3ed7bef989f268365e85800862e8ac756f
# bad: [d5c67bac833c6c9cc713f6a27daa77dcba898dd8] Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstream-linus
git bisect bad d5c67bac833c6c9cc713f6a27daa77dcba898dd8
# good: [0d63e4f9ea61df1d727bd52a174aba732e6e1853] Dont touch fs_struct in drivers
git bisect good 0d63e4f9ea61df1d727bd52a174aba732e6e1853
# good: [7d8330a563b00040326084f933f5bee06675ac54] KVM is not seen under X86 config with latest git (32 bit compile)
git bisect good 7d8330a563b00040326084f933f5bee06675ac54
# good: [30b3cfe1f67550bb6ec6868507a78060ef98269a] [ATYFB]: Kill 'prom_palette' sparc code.
git bisect good 30b3cfe1f67550bb6ec6868507a78060ef98269a
# bad: [b69409279c4c960fcd1575bcf80f2a0ca414ca93] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
git bisect bad b69409279c4c960fcd1575bcf80f2a0ca414ca93
# good: [45b503548210fe6f23e92b856421c2a3f05fd034] [RTNETLINK]: Send a single notification on device state changes.
git bisect good 45b503548210fe6f23e92b856421c2a3f05fd034
# bad: [c58310bf4933986513020fa90b4190c7492995ae] Merge git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6 into for-linus
git bisect bad c58310bf4933986513020fa90b4190c7492995ae
# good: [f527cf405017e60ceb28f84e2d60ab16fc34f209] Merge branch 'slab-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm
git bisect good f527cf405017e60ceb28f84e2d60ab16fc34f209
# good: [96f2fc006c281cbd5702a409c57d1f1549cde1fe] sh: Clean up whitespace damage in Kconfig.debug.
git bisect good 96f2fc006c281cbd5702a409c57d1f1549cde1fe
# good: [5c8f82c64941594cdab53bf9f9a66c190781f4f6] maple: Fix up maple build failure.
git bisect good 5c8f82c64941594cdab53bf9f9a66c190781f4f6
# good: [e036eaa681a17f71b64f6d9040fe605555623919] sh: use ctrl_in/out for on chip pci access
git bisect good e036eaa681a17f71b64f6d9040fe605555623919
# good: [11d64be6a631236b3b3d21711c7d1a83d9f85904] Merge git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6
git bisect good 11d64be6a631236b3b3d21711c7d1a83d9f85904
# bad: [f6866fecd6fd8e44a6715da09844a4fd1b8484da] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
git bisect bad f6866fecd6fd8e44a6715da09844a4fd1b8484da
# good: [4ee29f6a52158cea526b16a44ae38643946103ec] Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jikos/hid
git bisect good 4ee29f6a52158cea526b16a44ae38643946103ec
# good: [0f4bda005fd685f7cbb2ad47b7bab1b155df2b86] net: xfrm statistics depend on INET
git bisect good 0f4bda005fd685f7cbb2ad47b7bab1b155df2b86
# good: [073a371987f9a9806a85329eed51dca1fc52a7a0] [XFRM]: Avoid bogus BUG() when throwing new policy away.
git bisect good 073a371987f9a9806a85329eed51dca1fc52a7a0
# bad: [69c3683ca7fe066ecba9e8a0424c5abd258a5d58] netconsole: avoid null pointer dereference at show_local_mac()
git bisect bad 69c3683ca7fe066ecba9e8a0424c5abd258a5d58
# bad: [b5c15fc004ac83b7ad280acbe0fd4bbed7e2c8d4] [IPV6]: Fix reversed local_df test in ip6_fragment
git bisect bad b5c15fc004ac83b7ad280acbe0fd4bbed7e2c8d4

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
