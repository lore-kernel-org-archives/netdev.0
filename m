From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: [PATCH 4/4] [Net] Support accelerated network
	plugin modules
Date: Fri, 15 Jun 2007 17:22:43 +0100
Message-ID: <1181924563.4121.94.camel@moonstone.uk.level5networks.com>
References: <1181904393.4121.55.camel@moonstone.uk.level5networks.com>
	<4e777ed10706150859r3b6e1617o3b31e5e24a30e6c9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	herbert@gondor.apana.org.au
To: Zhu Han <schumi.han@gmail.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <4e777ed10706150859r3b6e1617o3b31e5e24a30e6c9@mail.gmail.com>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Fri, 2007-06-15 at 11:59 -0400, Zhu Han wrote:
> Hi, Kieran,
> 
> I'm just wonder why you try to acquire the lock and increase the
> hooks_usecount each time when you use the hook routine. Is there any
> generic ways to synchronze the code path using hook routines and
> netfront_accelerator_unloaded, considering you can synchronize the
> tx/rx data path easily.

The lock protects the use_count variable.  The use_count variable
prevents the plugin module unloading while it is being used.  I couldn't
just use the lock to prevent the module unloading as the hook function
(i) might block (and holding a spin_lock would be rather antisocial)
(ii) might call back into netfront and try to take the lock again, which
would deadlock.

The data path hooks do not block, and are already protected by locks, so
these are also taken when trying to unload the plugin module.  For this
reason it's not necessary to use the hooks_usecount on the data path.

I think that RCU would only work in this situation if the hook functions
didn't block, and wouldn't affect the data path locking overhead as it
wouldn't be necessary there.  

Kieran
