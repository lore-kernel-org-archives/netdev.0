From: Michael Vittrup Larsen <michael.vittrup.larsen@ericsson.com>
Subject: Re: [PATCH] tcp: efficient port randomisation (revised)
Date: Fri, 19 Nov 2004 08:38:37 +0100
Message-ID: <200411190838.37802.michael.vittrup.larsen@ericsson.com>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net> <200411051103.59032.michael.vittrup.larsen@ericsson.com> <20041117153025.160eaa04@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041117153025.160eaa04@zqx3.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have looked through this patch and found no problems - thank you for 
implementing the draft.

/Michael

On Thursday 18 November 2004 00:30, Stephen Hemminger wrote:
> Here is a more conservative version of earlier patch vthat keeps the same
> port rover locking and global port rover. This randomizes TCP ephemeral
> ports of incoming connections using variation of existing sequence number
> hash.
>
> Thanks to original author Michael Larsen.
> http://www.ietf.org/internet-drafts/draft-larsen-tsvwg-port-randomisation-0
>0.txt
>
> It behaves correctly if someone is perverse and sets low > high
> and it separates the outgoing port rover (tcp_port_rover) from the incoming
> port rover (start_rover).
>
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
>
> diff -Nru a/drivers/char/random.c b/drivers/char/random.c
> --- a/drivers/char/random.c 2004-11-17 15:21:43 -08:00
> +++ b/drivers/char/random.c 2004-11-17 15:21:43 -08:00
> @@ -2347,6 +2347,24 @@
>   return halfMD4Transform(hash, keyptr->secret);
>  }
>
> +/* Generate secure starting point for ephemeral TCP port search */
> +u32 secure_tcp_port_ephemeral(__u32 saddr, __u32 daddr, __u16 dport)
> +{
> + struct keydata *keyptr = get_keyptr();
> + u32 hash[4];
> +
> + /*
> +  *  Pick a unique starting offset for each ephemeral port search
> +  *  (saddr, daddr, dport) and 48bits of random data.
> +  */
> + hash[0] = saddr;
> + hash[1] = daddr;
> + hash[2] = dport ^ keyptr->secret[10];
> + hash[3] = keyptr->secret[11];
> +
> + return halfMD4Transform(hash, keyptr->secret);
> +}
> +
>  #ifdef CONFIG_SYN_COOKIES
>  /*
>   * Secure SYN cookie computation. This is the algorithm worked out by
> diff -Nru a/include/linux/random.h b/include/linux/random.h
> --- a/include/linux/random.h 2004-11-17 15:21:43 -08:00
> +++ b/include/linux/random.h 2004-11-17 15:21:43 -08:00
> @@ -52,6 +52,7 @@
>  void generate_random_uuid(unsigned char uuid_out[16]);
>
>  extern __u32 secure_ip_id(__u32 daddr);
> +extern u32 secure_tcp_port_ephemeral(__u32 saddr, __u32 daddr, __u16
> dport); extern __u32 secure_tcp_sequence_number(__u32 saddr, __u32 daddr,
> __u16 sport, __u16 dport);
>  extern __u32 secure_tcp_syn_cookie(__u32 saddr, __u32 daddr,
> diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> --- a/net/ipv4/tcp_ipv4.c 2004-11-17 15:21:43 -08:00
> +++ b/net/ipv4/tcp_ipv4.c 2004-11-17 15:21:43 -08:00
> @@ -636,6 +636,13 @@
>   return -EADDRNOTAVAIL;
>  }
>
> +static inline u32 connect_port_offset(const struct sock *sk)
> +{
> + const struct inet_opt *inet = inet_sk(sk);
> + return secure_tcp_port_ephemeral(inet->rcv_saddr, inet->daddr,
> +      inet->dport);
> +}
> +
>  /*
>   * Bind a port for a connect operation and hash it.
>   */
> @@ -647,10 +654,12 @@
>   int ret;
>
>    if (!snum) {
> -   int rover;
> -   int low = sysctl_local_port_range[0];
> -   int high = sysctl_local_port_range[1];
> -   int remaining = (high - low) + 1;
> +   const u16 low = sysctl_local_port_range[0];
> +   const u16 high = sysctl_local_port_range[1];
> +   u16 rover = low;
> +   int remaining = (high-low) + 1;
> +  u32 offset = connect_port_offset(sk);
> +  static u32 rover_start;
>    struct hlist_node *node;
>     struct tcp_tw_bucket *tw = NULL;
>
> @@ -660,7 +669,7 @@
>      * tcp_portalloc_lock before next submission to Linus.
>      * As soon as we touch this place at all it is time to think.
>      *
> -    * Now it protects single _advisory_ variable tcp_port_rover,
> +    * Now it protects single _advisory_ variable rover_start,
>      * hence it is mostly useless.
>      * Code will work nicely if we just delete it, but
>      * I am afraid in contented case it will work not better or
> @@ -670,12 +679,9 @@
>      * memory pingpong. Any ideas how to do this in a nice way?
>      */
>     spin_lock(&tcp_portalloc_lock);
> -   rover = tcp_port_rover;
> -
> -   do {
> -    rover++;
> -    if ((rover < low) || (rover > high))
> -     rover = low;
> +  while (remaining > 0) {
> +   rover = low + (rover_start + offset) %
> +    (high - low);
>      head = &tcp_bhash[tcp_bhashfn(rover)];
>      spin_lock(&head->lock);
>
> @@ -706,8 +712,9 @@
>
>     next_port:
>      spin_unlock(&head->lock);
> -   } while (--remaining > 0);
> -   tcp_port_rover = rover;
> +   --remaining;
> +   ++rover_start;
> +   }
>     spin_unlock(&tcp_portalloc_lock);
>
>     local_bh_enable();
> @@ -716,7 +723,6 @@
>
>  ok:
>     /* All locks still held and bhs disabled */
> -   tcp_port_rover = rover;
>     spin_unlock(&tcp_portalloc_lock);
>
>     tcp_bind_hash(sk, tb, rover);
