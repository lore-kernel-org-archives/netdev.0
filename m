From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 02/86] dccp: revert buggy auto-loading of dccp module
Date: Mon, 1 Feb 2010 13:38:40 -0500
Message-ID: <20100201183840.GF25094@hmsreliant.think-freely.org>
References: <recent-dccp-bug-fixes-jan-2010>
 <1265005087-5549-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1265005087-5549-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1265005087-5549-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <20100201122119.GC25094@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52246 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755549Ab0BASit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 13:38:49 -0500
Content-Disposition: inline
In-Reply-To: <20100201122119.GC25094@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 01, 2010 at 07:21:19AM -0500, Neil Horman wrote:
> On Mon, Feb 01, 2010 at 07:18:07AM +0100, Gerrit Renker wrote:
> > This reverts commit (38ff3e6bb987ec583268da8eb22628293095d43b) ("dccp_probe:
> > Fix module load dependencies between dccp and dccp_probe", from 15 Jan). Not
> > only does it not work:
> > 
> > % modprobe -v dccp_probe
> > kernel: [ 1431.442912] sys_init_module: 'dccp_probe'->init suspiciously \
> >  		      returned 1, it should follow 0/-E convention
> > kernel: [ 1431.442915] sys_init_module: loading module anyway...
> > 
> > 
> > ... but it also causes a crash:
> > 
> > % rmmod dccp_probe
> > kernel: [ 1777.305846] kernel BUG at /usr/src/davem-2.6/mm/slab.c:521!
> > kernel: [ 1777.305852] invalid opcode: 0000 [#1] SMP
> > kernel: [ 1777.305861] last sysfs file: /sys/class/power_supply/BAT0/energy_full
> > kernel: [ 1777.305867] Modules linked in: dccp_probe(-) iwl3945 iwlcore [last unloaded: dccp]
> > kernel: [ 1777.305883]
> > kernel: [ 1777.305891] Pid: 12912, comm: rmmod Tainted: G  R        2.6.33-rc5 #6 2008URG/2008URG
> > kernel: [ 1777.305899] EIP: 0060:[<c01d5e43>] EFLAGS: 00010046 CPU: 1
> > kernel: [ 1777.305910] EIP is at kfree+0x73/0x150
> > kernel: [ 1777.305916] EAX: c1678c00 EBX: 00000000 ECX: c01d5e15 EDX: 40080000
> > kernel: [ 1777.305922] ESI: c015cb9a EDI: 080488a0 EBP: f4ffbf34 ESP: f4ffbf10
> > kernel: [ 1777.305929]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> > kernel: [ 1777.305936] Process rmmod (pid: 12912, ti=f4ffb000 task=f61e8620 task.ti=f4ffb000)
> > 
> > ==> After reverting the commit:
> > 
> > % modprobe -v dccp_probe
> > insmod /lib/modules/2.6.33-rc5/kernel/net/dccp/dccp.ko
> > insmod /lib/modules/2.6.33-rc5/kernel/net/dccp/dccp_probe.ko
> > 
> > % lsmod
> > Module                  Size  Used by
> > dccp_probe              2345  0
> > dccp                  120233  1 dccp_probe
> > 
> > Previously (during about 4 years of this module's history) there had never
> > been a problem with the 'silent dependency' that the commit tried to fix:
> > this dependency is deliberate and required, since dccp_probe performs probing
> > of dccp connections and hence needs to know about dccp internals.
> > 
> > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> 
> This doesn't make any sense.  Gerrit, you don't understand what the patch was
> trying to do.  There is a silent dependency, in that this module requires the
> dccp module to be loaded, but the reference to the dccp_send_probe symbol isn't
> one that depmod can see.  If you don't load dccp first, dccp_probe fails, why
> bother to allow that when try_then_request_module can avoid it?
> 
> The problem here is the construction of the first argument,
> try_then_request_module should only return valid return codes from the first
> argument, and my first argument is malformed.  register_jprobe returns zero on
> success, so I need to check its return in the call for 0, in case we need to
> trigger the request_module action, but in so doing ret gets the value of
> (register_jprobe(&dccp_send_probe) == 0), which will always be 0 or 1.  What we
> actually need to do is assign the result of register_jprobe to ret, without the
> side effect of the comparison.  I've not tested it, but this should do it,
> without re-breaking the silent dependency.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> 
>  
>  probe.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> 
> diff --git a/net/dccp/probe.c b/net/dccp/probe.c
> index bace1d8..a8f5fdf 100644
> --- a/net/dccp/probe.c
> +++ b/net/dccp/probe.c
> @@ -161,7 +161,8 @@ static __init int dccpprobe_init(void)
>  	if (!proc_net_fops_create(&init_net, procname, S_IRUSR, &dccpprobe_fops))
>  		goto err0;
>  
> -	ret = try_then_request_module((register_jprobe(&dccp_send_probe) == 0),
> +	try_then_request_module(
> +		((ret = register_jprobe(&dccp_send_probe)) == 0),
>  					"dccp");
>  	if (ret)
>  		goto err1;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Gerrit, any thoughts here?
Thanks & Regards
Neil

