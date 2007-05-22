From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: Re: [PATCH 3/4] [Net] Support Xen accelerated
	network plugin modules
Date: Tue, 22 May 2007 17:06:11 +0100
Message-ID: <1179849971.28562.85.camel@moonstone.uk.level5networks.com>
References: <C2785EC4.F4E3%keir@xensource.com>
	<1179837868.28562.22.camel@moonstone.uk.level5networks.com>
	<20070522080512.6c9528a1@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: muli@il.ibm.com, netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	Keir Fraser <keir@xensource.com>, herbert@gondor.apana.org.au
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <20070522080512.6c9528a1@freepuppy>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Tue, 2007-05-22 at 08:05 -0700, Stephen Hemminger wrote:

> The same thing is already done to handle network protocols already.
> RCU is used for the object handle (including function pointers).
> You need to use:
>   * put rcu structure in accelerator list member
>     and initialize it to the callback
>   * on addition increase refcount
> on deletion
>   * call list_del_rcu() on removal
>   * in rcu callback you do last step
> 	like drop module refcount and free.

Apologies for coming back to this, but I want to make sure this is going
to work before I write the code.

The current scheme uses a spin lock to protect the list and a reference
count for each item on that list.  This reference count is initialised
to 1 when the accelerator module is loaded, incremented before each call
into the accelerator, decremented after it, and decremented when the
module's exit function is called as a result of rmmod being called on
the module.  rmmod is then blocked.  When the ref count reaches zero the
function pointers are set to NULL, resulting in no more calls into the
accelerator module, and the rmmod is unblocked.  The accelerator now
exits safely.

The critical bits I don't understand about your suggested scheme are:
 i) how deletion/list_del_rcu() is triggered (see below);
 ii) how it prevents the accelerated module being unloaded in the middle
of call into that module. 

I assume you're suggesting using the module use count to solve (ii), but
this essentially causes (i):  if we increase the module use count for
each interface using the accelerator we can never unload the module
because there's no mechanism to request that an interface stop being
accelerated (and so decrease the ref count).

If you're suggesting using RCU to protect against the hooks being
modified during a call into them, that's only allowed if the protected
region doesn't block, and I'm not convinced that the protected regions
here (the calls into the accelerator module) will never block.

Apologies again if I've misinterpreted your suggestion,

Kieran
