From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: e1000e: 1 second spins in
	e1000_acquire_swflag_ich8lan?
Date: Sun, 26 May 2013 11:46:34 -0500
Message-ID: <20130526164634.GA7241@lintop.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

My laptop was struggling to play youtube videos this morning so I took
a peek in top and noticed the watchdog/1 thread hogging my CPU.  Next
step I take a peek with perf:

49.57%   kworker/1:1  [kernel.kallsyms]                   [k] native_read_tsc
         |
         --- native_read_tsc
            |
            |--92.49%-- delay_tsc
            |          __const_udelay
            |          e1000_acquire_swflag_ich8lan
            |          e1000e_read_phy_reg_igp
            |          e1000e_phy_has_link_generic
            |          e1000_check_for_copper_link_ich8lan
            |          e1000e_has_link
            |          e1000_watchdog_task
            |          process_one_work
            |          worker_thread
            |          kthread
            |          ret_from_fork

Alright, so we're callingn udelay from e1000_acquire_swflag_ich8lan.
How often and for how long?  I take a look with trace-cmd:

kworker/1:2-23734 [001]  3971.629095: funcgraph_entry:                   |    e1000_acquire_swflag_ich8lan() {
kworker/1:2-23734 [001]  3971.629098: funcgraph_entry:      ! 999.674 us |      delay_tsc();
kworker/1:2-23734 [001]  3971.630100: funcgraph_entry:      ! 999.639 us |      delay_tsc();
kworker/1:2-23734 [001]  3971.631101: funcgraph_entry:      ! 999.639 us |      delay_tsc();
<snip>...<snip>
kworker/1:2-23734 [001]  3972.630995: funcgraph_exit:       ! 1001899 us |    }

So I see it calls mdelay(1) over and over again for a total of 1
second.  Looks like I'm getting stuck in this bit of code where
SW_FLAG_TIMEOUT is 1 second:

        timeout = SW_FLAG_TIMEOUT;

        extcnf_ctrl |= E1000_EXTCNF_CTRL_SWFLAG;
        ew32(EXTCNF_CTRL, extcnf_ctrl);

        while (timeout) {
                extcnf_ctrl = er32(EXTCNF_CTRL);
                if (extcnf_ctrl & E1000_EXTCNF_CTRL_SWFLAG)
                        break;

                mdelay(1);
                timeout--;
        }

I guess I have two questions:  

1) Do these need to be mdelays instead of msleeps?  It looks like in
my case this is called from process context, but I didn't audit all of
the callers of this function and maybe it can happen from interrupt
context too?

2) Any idea why I'm hitting this in the first place?

$ lspci | grep Ether
00:19.0 Ethernet controller: Intel Corporation 82566MM Gigabit Network Connection (rev 03)
$ ethtool -i eth0
driver: e1000e
version: 2.2.14-k
firmware-version: 0.3-0
bus-info: 0000:00:19.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no
$ uname -r
3.9.3-201.fc18.x86_64

Thanks,
Shawn


------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
