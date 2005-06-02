From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.12-rc5-mm2: "bic unavailable using TCP reno" messages
Date: Thu, 2 Jun 2005 10:38:05 -0700
Message-ID: <20050602103805.6beb4f4e@dxpl.pdx.osdl.net>
References: <20050601022824.33c8206e.akpm@osdl.org>
	<20050602121511.GE4992@stusta.de>
	<429F1079.5070701@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, Andrew Morton <akpm@osdl.org>,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <429F1079.5070701@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 02 Jun 2005 14:58:17 +0100
Baruch Even <baruch@ev-en.org> wrote:

> Adrian Bunk wrote:
> > On Wed, Jun 01, 2005 at 02:28:24AM -0700, Andrew Morton wrote:
> > 
> >>...
> >>Changes since 2.6.12-rc5-mm1:
> >>...
> >>+tcp-tcp_infra.patch
> >>...
> >> Steve Hemminger's TCP enhancements.
> >>...
> > 
> > 
> > I said "no" to CONFIG_TCP_CONG_BIC, and now my syslog is full of messages
> >    kernel: bic unavailable using TCP reno
> > 
> > I have no problem with such a message being shown once - but once should 
> > be enough.  
> 
> The best solution for this would be to check the available protocols at
> setup time and not at connection creation time. This would also provide
> a better feedback to the user, since he will either see that what he set
> was taken, or it wasn't.
> 
> In the current mechanism you can set the protocol to 'foo' and it will
> show back as 'foo'. You'll get complaints only once a connection is
> attempted with this protocol.
> 
> It does mean some extra work in the sysctl stage, but it's better IMO to
> do it there rather than at connection setup time.
> 
> Baruch

Your right, the sysctl handler should be smarter, but that is not the problem here.
The problem is that the default value is set to be BIC to be compatible with earlier kernels.
Since 75% of the world isn't smart enough to figure out how to use sysctl, there is a
question of what the default should be, and what to do if that is missing.

One version had a messy ifdef chain to try and avoid the warning:

char sysctl_tcp_congestion_control[] = 
#if defined(CONFIG_TCP_BIC)
	"bic"
#elif defined(CONFIG_TCP_HTCP)
	"htcp"
#else
	"reno"
#endif
	;

but that was ugly.

Another possibility is putting it in as yet another config value at kernel build time.

To suppress the warning repeating, probably the best solution would be rewrite the string
if we have to revert to reno. But carefully to avoid SMP issues.  This also implies a smarter
sysctl string handler for this value as well.

P.s: saw your comparison paper, after a little more corroboration I would like to make
H-TCP the default.
