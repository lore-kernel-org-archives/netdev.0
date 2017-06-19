From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH net-next v2 10/15] bpf: Add support for changing congestion
 control
Date: Tue, 20 Jun 2017 00:34:06 +0200
Message-ID: <5948515E.1090607@iogearbox.net>
References: <20170615200844.2752485-1-brakmo@fb.com> <20170615200844.2752485-11-brakmo@fb.com> <5943E41F.2050006@iogearbox.net> <59B6F12A-9740-4177-BCB3-72CD65EB1225@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <Kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55341 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750903AbdFSWe3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 18:34:29 -0400
In-Reply-To: <59B6F12A-9740-4177-BCB3-72CD65EB1225@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2017 04:39 AM, Lawrence Brakmo wrote:
> On 6/16/17, 6:58 AM, "Daniel Borkmann" <daniel@iogearbox.net> wrote:
[...]
>      >   /* Change congestion control for socket */
>      > -int tcp_set_congestion_control(struct sock *sk, const char *name)
>      > +int tcp_set_congestion_control(struct sock *sk, const char *name, bool load)
>      >   {
>      >   	struct inet_connection_sock *icsk = inet_csk(sk);
>      >   	const struct tcp_congestion_ops *ca;
>      > @@ -344,7 +344,10 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
>      >   		return -EPERM;
>      >
>      >   	rcu_read_lock();
>      > -	ca = __tcp_ca_find_autoload(name);
>      > +	if (!load)
>      > +		ca = tcp_ca_find(name);
>      > +	else
>      > +		ca = __tcp_ca_find_autoload(name);
>
>       From BPF program side, we call with !load since we're not allowed
>      to sleep under RCU, that's correct ...
>
>      >   	/* No change asking for existing value */
>      >   	if (ca == icsk->icsk_ca_ops) {
>      >   		icsk->icsk_ca_setsockopt = 1;
>      > @@ -352,8 +355,10 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
>      >   	}
>      >   	if (!ca)
>      >   		err = -ENOENT;
>      > +	else if (!load)
>      > +		icsk->icsk_ca_ops = ca;
>
>      ... but don't we also need to hold a module ref in this case as done
>      below?
>
>      Meaning, tcp_ca_find() could return a ca that was previously loaded
>      to the tcp_cong_list as module, then resulting in ref count imbalance
>      when set from BPF?
>
> As I mentioned above, this can be called before congestion has been
> initialized (op <= BPF_SOCKET_OPS_NEEDS_ECN) in which case
> tcp_init_congestion_control will be called later. If op > ..OPS_NEEDS_ECN
> then bpf_setsockopt() will call the reinit_congestion_control().
>
> But this points to an issue where someone else could call
> tcp_set_congestion_control() with load == false not knowing they
> need to call either init or reinit. I will add a comment to the function
> to make it clear.

Hm, I'm not sure it answers my question. What I meant was that from BPF
prog, you're setting tcp_set_congestion_control(..., false) so if
tcp_ca_find() returns a ca that was loaded earlier as a from a module
(so it becomes available in tcp_cong_list), the above...

   [...]
   else if (!load)
       icsk->icsk_ca_ops = ca;
   [...]

... will basically prevent the later try_module_get() on the ca. So any
later tcp_reinit_congestion_control() or tcp_init_congestion_control()
will still run not having the refcount held on the owner module. Meaning
a module unload would let the machine crash due to the refcnt imbalance?
What am I missing?
