From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: Patch submission for S2io Xframe driver to 2.6 kernel
Date: Fri, 20 Aug 2004 23:21:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040820232119.0b53148a.rddunlap@osdl.org>
References: <001401c48194$62497260$9610100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, leonid.grossman@s2io.com,
        raghavendra.koushik@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: <ravinandan.arakali@s2io.com>
In-Reply-To: <001401c48194$62497260$9610100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 13 Aug 2004 17:19:36 -0700 Ravinandan Arakali wrote:

| Hi Jeff et al,
| We gained immensely from your code review comments last time when we
| submitted the S2io driver.
| Attached is a patch(use with -p1 option from /usr/src/<kernel_name>
| directory) on the current driver
| in the 2.6 kernel. Please review the code changes and reply with your
| valuable comments.
| 
| Briefly, some of the main features in this patch:
| 
| 1. Support for IBM PowerPC platform.
| 2. Support for NAPI.
| 3. More efficient allocation of Transmit blocks.
| 4. Multi-buffer mode for improved Receive performance.
| 4. Following bug fixes:
|    a. Race condition when trying to down interface during traffic.
|    b. Fix for bringup problems with SuSE9 on IA64 system.


for s2io.c::::::::::

0.  Renames a bunch of functions.  It would be helpful (for patch reviewers)
to separate this into functional patch sets.  That way, things like
function renames (and kerneldoc style function comment blocks -- which are
much better, thanks -- wouldn't get in the way of reviewing the meat of
the patch.

a.  It needs some fixups for coding style.
Current s2io.c has these right, but the patch messes them up:

use a space after "if" and "for", not "if(" or "for("

b.  This code fragment (done 2 times):

+		int tmp =  config->TxCfg[i].FifoLen / lst_per_page;
+		int tmp1 =  config->TxCfg[i].FifoLen % lst_per_page;
+		int page_num = tmp1? (tmp+1) : tmp;

looks like a familiar idiom to me:

#define container_index(len, per_each)	((len + per_each - 1) / per_each)

		page_num = container_index(config->TxCfg[i].FifoLen, lst_per_page);

c.  in this code fragment:


+			int k = 0;
+			dma_addr_t tmp_p;
+			void *tmp_v;	
+			tmp_v = pci_alloc_consistent(nic->pdev,
+					PAGE_SIZE, &tmp_p);
+			if(!tmp_v) {
+				DBG_PRINT(ERR_DBG,"Malloc failed for TxDL\n");
Using "Malloc" here would be confusing to me, but it's DBG_PRINT(), so....

+				return -ENOMEM;
+			}
+			memset(tmp_v, 0, PAGE_SIZE);
memset() is done by the alloc call.


d.  long comment format in Linux is:

/*
 * begin here
 * more comment
 * still more
 * end here
 */

e.  s/chachelines/cachelines/  (or /cache lines/)

f.  There are several function description blocks where the function
name in the comment block does not match the actual coded function name.

g.  check the return type and comment:

+ * Return value :
+ * void.
  */
+
 int s2io_ethtool_gset(

h.  read_eeprom():
+ * Return value:
+ *  -1 on failure and the value read from the Eeprom if successful.

so read_eeprom() doesn't distinguish between reading 0xff ff ff ff
and an error?

i.  write_eeprom():
probably returns 0 on success, not '0':
+ * Return value:
+ *  '0' on success, -1 on failure.
Just remove the ' marks.  (in multiple places)

j.  Please use tabs instead of spaces (e.g., 8 spaces at beginning of
some lines).

k.  in check parameter values:

+	if ((shared_splits > 31)) {
+		printk("shared_splits can exceed 31\n");
?                                     cannot ??

+	if (rmac_util_period > 0xF) {
+		printk("rmac_util_period can exceed 15\n");
?                                        cannot ??

+	if (tmac_util_period > 0xF) {
+		printk("tmac_util_period can exceed 15\n");
?                                        cannot ??



for s2io.h::::::::::::::::;

1.  It would be nice (desirable, preferred) to remove all of those typedefs,
similar to the way that you changed FuncTionNames and comments.

2.  +#define SIZE_OF_BLOCK	4096

Is this size strictly device specific, and not architecture related?


--
~Randy
