From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] SCTP: Reduce log spamming for sctp setsockopt
Date: Mon, 16 Dec 2013 08:50:35 -0800
Message-ID: <1387212635.18217.45.camel@joe-AO722>
References: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com>
	 <1387206233.18217.21.camel@joe-AO722> <52AF18B7.6050602@redhat.com>
	 <1387207301.18217.30.camel@joe-AO722> <52AF2001.2090108@redhat.com>
	 <20131216160440.GE19809@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0072.hostedemail.com ([216.40.44.72]:52727 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755035Ab3LPQuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 11:50:39 -0500
In-Reply-To: <20131216160440.GE19809@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-16 at 11:04 -0500, Neil Horman wrote:
> On Mon, Dec 16, 2013 at 04:45:05PM +0100, Daniel Borkmann wrote:
> > On 12/16/2013 04:21 PM, Joe Perches wrote:
> > >On Mon, 2013-12-16 at 16:13 +0100, Daniel Borkmann wrote:
> > >>On 12/16/2013 04:03 PM, Joe Perches wrote:
> > >>>On Mon, 2013-12-16 at 09:44 -0500, Neil Horman wrote:
> > >>>>During a recent discussion regarding some sctp socket options, it was noted that
> > >>>>we have several points at which we issue log warnings that can be flooded at an
> > >>>>unbounded rate by any user.  Fix this by converting all the pr_warns in the
> > >>>>sctp_setsockopt path to be pr_warn_ratelimited.
> > >>>
> > >>>trivial note:
> > >>[...]
> > >>>>@@ -5311,8 +5311,8 @@ static int sctp_getsockopt_maxburst(struct sock *sk, int len,
> > >>>[]
> > >>>>+		pr_warn_ratelimited("Use of int in max_burst socket option deprecated\n");
> > >>>>+		pr_warn_ratelimited("Use struct sctp_assoc_value instead\n");
> > >>>
> > >>>Perhaps a dedicated "deprecated" warning function
> > >>>to centralize these?
> > >>>
> > >>>void _sctp_warn_deprecated(const char *func, const char *from, const char *to);
> > >>>{
> > >>>	etc.
> > >>>}
> > >>>#define sctp_warn_deprecated(from, to)		\
> > >>>	_sctp_warn_deprecated(__func__, from, to)
> > >>
> > >>If so, then this should better get even more "centralized" ... as e.g.
> > >>pr_warn_deprecated() [which internally is ratelimited]. I don't see the
> > >>point why only SCTP should have this special-cased.
> > >
> > >Sure, if it's useful outside of sctp, but I didn't
> > >notice any other uses like it.
> > 
> > If we have a generic API for that, they might come, sure.
> I agree with Daniel.  If we're going to make this common, theres no reason to
> not make it common for all uses.  Searching the kernel for uses of printk/pr_*
> and the string "deprecated" shows lots of potential use sites.

Does adding a couple of functions like:

void pr_warn_deprecated(const char *old, const char *new)
{
	static DEFINE_RATELIMIT_STATE(_rs,
				      DEFAULT_RATELIMIT_INTERVAL,
				      DEFAULT_RATELIMIT_BURST);

	if (!__ratelimit(&_rs))
		return;

	if (new)
		printk(KERN_WARNING "%pf: Use of \"%s\" is deprecated - use \"%s\" instead\n",
				    __builtin_return_address(1), old, new); 
	else
		printk(KERN_WARNING "%pf: Use of \"%s\" is deprecated\n",
				    __builtin_return_address(1), old); 
}

suit?  Other suggestions?

Looking at a slightly old allyesconfig vmlinux, there are a few that
fit the pattern that could use this style function.  Others have
variant/inappropriate forms.

Most are at KERN_WARNING, though a few are KERN_INFO.

$ strings vmlinux.o.old |grep -i deprecat
deprecated_sysctl_warning
4%s (%d): Attempt to access syslog with CAP_SYS_ADMIN but no CAP_SYSLOG (deprecated).
6warning: process `%s' used the deprecated sysctl system call with 
6warning: `%s' uses deprecated v2 capabilities in a way that may be insecure.
Warning: clock=pmtmr is deprecated. Use clocksource=acpi_pm.
Warning! clock= boot option is deprecated. Use clocksource=xyz
4cgroup: option changes via remount are deprecated (pid=%d comm=%s)
3AUDIT_POSSIBLE is deprecated
4%s (%d): /proc/%d/oom_adj is deprecated, please use /proc/%d/oom_score_adj instead.
Ignoring deprecated oldalloc option
Ignoring deprecated orlov option
warning: ignoring deprecated nobh option
warning: ignoring deprecated bh option
4%s (%d): Using mlock ulimits for SHM_HUGETLB is deprecated
Option iocharset is deprecated. Please use option nls=<charsetname> in the future.
delaylog is the default now, option is deprecated.
nodelaylog support has been removed, option is deprecated.
ihashsize no longer used, option is deprecated.
osyncisdsync has no effect, option is deprecated.
osyncisosync has no effect, option is deprecated.
irixsgid is now a sysctl(2) variable, option is deprecated.
4btrfs: 'subvolrootid' mount option is deprecated and has no effect
4program %s is using a deprecated SCSI ioctl, please convert it to SG_IO
4dynamic_debug:%s: ddebug_query param name is deprecated, change it to dyndbg
6sisfb: Deprecated ioctl call received - update your application!
4ACPI: Deprecated procfs I/F for AC is loaded, please retry with CONFIG_ACPI_PROCFS_POWER cleared
4ACPI: Deprecated procfs I/F for battery is loaded, please retry with CONFIG_ACPI_PROCFS_POWER cleared
4ACPI: Deprecated procfs I/F for SBS is loaded, please retry with CONFIG_ACPI_PROCFS_POWER cleared
5%s sets custom speed on %s. This is deprecated.
4mxser: '%s' uses deprecated ioctl %x (GET_MAJOR), fix your userspace
4warning: 'lp=0x%x' is deprecated, ignored
4program %s is using a deprecated SCSI ioctl, please convert it to SG_IO
43w-xxxx: SCSI_IOCTL_SEND_COMMAND deprecated, please update your 3ware tools.
master is unqueued, this is deprecated
Enabling SR-IOV VFs using the module parameter is deprecated - please use the pci sysfs interface.
Enabling SR-IOV VFs using the module parameter is deprecated - please use the pci sysfs interface.
7%s: process %d (%s) used deprecated iwpriv monitor - update software to use iwconfig mode monitor
7rtl8192c_common:%s(): deprecated!
7rtl8723ae:%s(): deprecated!
Loaded firmware %s, which is deprecated.  Please use API v%u instead.
4wlcore: WARNING chip id 0x%x (185x PG10) is deprecated
4amb: rejecting open with unspecified VPI/VCI (deprecated)
4hrz: rejecting open with unspecified VPI/VCI (deprecated)
WARNING: firmware file name %s is deprecated, please rename to %s
4WARNING! power/level is deprecated; use power/control instead
[Ueagle-atm] use deprecated cmvs version, please update your firmware
%s: attach_adapter method is deprecated
4%s: Choosing the clock frequency based on index is deprecated. Use the nominal frequency.
Sensor type %d is deprecated, please use 4 instead
Sensor type %d is deprecated, please use 4 instead
Sensor type 2 is deprecated, please use 4 instead
4ib_srp: srp_sg_tablesize is deprecated, please use cmd_sg_entries
deprecated sysfs attribute
4thinkpad_acpi: WARNING: sysfs attribute %s is deprecated and will be removed. %s
3thinkpad_acpi: Please remove the hotkey=enable module parameter, it is deprecated.  Hotkeys are always enabled.
4Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev-%s instead.
6nf_conntrack: automatic helper assignment is deprecated and it will be removed soon. Use the iptables CT target to attach helpers instead.
6xt_CT: netfilter: NOTRACK target is deprecated, use CT instead or upgrade iptables
6ipt_ULOG: ULOG is deprecated and it will be removed soon, use NFLOG instead
4ICMPv6: process `%s' is using deprecated sysctl (%s) net.ipv6.neigh.%s.%s - use net.ipv6.neigh.%s.%s_ms instead
6ebt_ulog: ebt_ulog is deprecated and it will be removed soon, use ebt_nflog instead
4%s: sockopt(PACKET_SIZE) is deprecated: fix your app
4%s: sockopt(CHANGE_L/R) is deprecated: fix your app
4sctp: Use of struct sctp_assoc_value in delayed_ack socket option deprecated
4sctp: Use of int in maxseg socket option deprecated
4sctp: Use of int in max_burst socket option deprecated
4libceph: ignoring deprecated osdtimeout option
sysfs.deprecated
