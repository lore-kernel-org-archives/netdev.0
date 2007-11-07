From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 2/2]: e1000: avoid lockup durig error
	recovery
Date: Wed, 7 Nov 2007 17:21:19 -0600
Message-ID: <20071107232119.GQ4239@austin.ibm.com>
References: <20071107211935.GH4239@austin.ibm.com>
	<20071107212404.GA15251@austin.ibm.com> <47323319.10709@intel.com>
	<20071107222446.GM4239@austin.ibm.com> <47323FFE.2060008@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	NetDev <netdev@vger.kernel.org>,
	"Brandeburg,  Jesse" <jesse.brandeburg@intel.com>,
	john.ronciak@intel.com, jeffrey.t.kirsher@intel.com,
	'Stephen Hemminger' <shemminger@linux-foundation.org>,
	wenxiong@us.ibm.com
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <47323FFE.2060008@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Nov 07, 2007 at 02:45:18PM -0800, Kok, Auke wrote:
> [adding netdev, jeff G to the Cc]
> 
> Linas Vepstas wrote:
> > On Wed, Nov 07, 2007 at 01:50:17PM -0800, Kok, Auke wrote:
> >> Linas Vepstas wrote:
> >>> If a PCI bus error is encountered during device open, the
> >>> error recovery routines will attempt to close the device.
> >>> If napi has not yet been enabled, the napi disable in the
> >>> close will hang. 
> >>>
> >>> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> >>>
> >>> ----
> >>> The "elegence" of this solution is arguable: one could
> >>> say its "better" to perform this check in e1000_down().
> >>> However, doing so will disrupt a commonly used path,
> >>> whereas here, the hack is in the infrequently used
> >>> error path, and thus less intrusive. 
> >>>
> >>>  drivers/net/e1000/e1000_main.c |    9 ++++++++-
> >>>  1 file changed, 8 insertions(+), 1 deletion(-)
> >>>
> >> I think this is OK, but it's quite awful looking if you ask me.
> > 
> > Yeah, ... 
> > 
> > There are several alternatives: below are two. If you
> > find one to be more appealing.. could you use it? Consider them
> > to be "signed-off-by"; I have not actually compiled or tested
> > either of them.
> 
> I'm not a particular fan of putting extra state tracking in the driver for
> something we could extract from the napi subsystem already.
> 
> Jeff, Stephen, can't we have a generic napi_enabled() inline in netdevice.h that
> tests for NAPI_STATE_SCHED ?

Like this?

 include/linux/netdevice.h |   12 ++++++++++++
 1 file changed, 12 insertions(+)

Index: linux-2.6.23-rc8-mm1/include/linux/netdevice.h
===================================================================
--- linux-2.6.23-rc8-mm1.orig/include/linux/netdevice.h	2007-09-26 15:07:05.000000000 -0500
+++ linux-2.6.23-rc8-mm1/include/linux/netdevice.h	2007-11-07 17:14:50.000000000 -0600
@@ -384,6 +384,18 @@ static inline void napi_enable(struct na
 	clear_bit(NAPI_STATE_SCHED, &n->state);
 }
 
+/**
+ *	napi_enabled_p - return non-zero if napi enabled
+ *	@n: napi context
+ * 
+ * Mnemonic: _p stands for "predicate", returning a yes/no
+ * answer to the question.
+ */
+static inline int napi_enabled_p(struct napi_struct *n)
+{
+	return !test_bit(NAPI_STATE_SCHED, &n->state);
+}
+
 /*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O


> I wonder if there isn't something in the PCI error recovery missing the point and
> we can solve this problem better for all drivers somehow.

Well, there's also scsi, which doesn't use napi :-)
For the most part, error recovery is a fairly cut-n-paste
set of steps. However, I don't quite have enough confidence
to say "yea verily, all network adapters will use these 
same steps."

--linas

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
