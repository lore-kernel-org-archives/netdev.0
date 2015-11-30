From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] bridge: Only call /sbin/bridge-stp for the
 initial network namespace
Date: Mon, 30 Nov 2015 14:12:08 -0800
Message-ID: <20151130141208.516b1046@xeon-e3>
References: <565B7F7D.80208@nod.at>
	<CAGXu5jJqQKAmFK0nL69E0QOpo8WSVDqStGZo7-m7gy3vnXBa=A@mail.gmail.com>
	<87egf7183c.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>, "kernel-hardening@lists.openwall.com"
	<kernel-hardening@lists.openwall.com>, Richard Weinberger <richard@nod.at>,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <87egf7183c.fsf_-_@x220.int.ebiederm.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Nov 2015 15:38:15 -0600
ebiederm@xmission.com (Eric W. Biederman) wrote:

> 
> There is no defined mechanism to pass network namespace information
> into /sbin/bridge-stp therefore don't even try to invoke it except
> for bridge devices in the initial network namespace.
> 
> It is possible for unprivileged users to cause /sbin/bridge-stp to be
> invoked for any network device name which if /sbin/bridge-stp does not
> guard against unreasonable arguments or being invoked twice on the same
> network device could cause problems.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  net/bridge/br_stp_if.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
> index 5396ff08af32..742fa89528ab 100644
> --- a/net/bridge/br_stp_if.c
> +++ b/net/bridge/br_stp_if.c
> @@ -142,7 +142,9 @@ static void br_stp_start(struct net_bridge *br)
>  	char *envp[] = { NULL };
>  	struct net_bridge_port *p;
>  
> -	r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
> +	r = -ENOENT;
> +	if (dev_net(br->dev) == &init_net)
> +		r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);

I don't think this will cause loud screams.
But it might break people that use containers to run virtual networks for testing.

One coding nit:
Why are you afraid of using an else?
