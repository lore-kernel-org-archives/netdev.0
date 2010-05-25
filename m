From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH net-next] ixgbe: make macvlan on PF
 working when SRIOV is enabled
Date: Tue, 25 May 2010 10:15:45 -0700
Message-ID: <1274807745.18023.71.camel@localhost.localdomain>
References: <1274806509.18023.58.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	gregory.v.rose@intel.com, "davem@davemloft.net" <davem@davemloft.net>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1274806509.18023.58.camel@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

To produce this problem:

1. modprobe ixgbe max_vfs=2 
   eth4 is PF, eth5 is VF
2. ip link set eth4 up
3. ip link add link eth4 address 54:52:00:35:e3:20 macvlan2 type macvlan
4. ip addr add 192.168.7.74/24 dev macvlan2
5. ping macvlan2 from remote host, works
6. ip link set eth5 up
7. ping macvlan2 from remote host failed.

Based on my understanding, the problem is:
1. PF set_rar use rar index is 0, and vmdq index is adapter->num_vfs, 
2. when macvlan2 is created, rar index is based rar_used_count, which
would be 1.
3. later when VF is up, the rar index is vf+1, and vmdq index is vf, so
VF0 will overwrite macvlan2 rar entry.

The fix here:
1. make sure PF uses vmdq index = adapter->num_vfs during
initialization, reset.
2. reserve rar index for all VFs from 1 to num_vfs + 1.


Please let me know whether my understanding is correct or not.

Thanks
Shirley


------------------------------------------------------------------------------

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
