From: "Leigh Brown" <leigh@solinno.co.uk>
Subject: Re: kernel panic with the newly merged md5 signature support
Date: Tue, 12 Dec 2006 22:22:13 -0000 (GMT)
Message-ID: <60194.81.105.127.245.1165962133.squirrel@www.solinno.co.uk>
References: <36718.81.105.127.245.1165873138.squirrel@www.solinno.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mwuml021.modern-world.net ([193.110.88.84]:2525 "EHLO
	mwuml021.modern-world.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932482AbWLLWWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 17:22:15 -0500
In-Reply-To: <36718.81.105.127.245.1165873138.squirrel@www.solinno.co.uk>
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, December 11, 2006 9:38 pm, I said:
> I decided to try out the md5 signature support, with a view to eventually
> fixing up Quagga to make use of it.  As the API has changed quite a bit,
> I modified a simple echo client/server as a simple test.  I compiled
> up 2.6.19-git17 and ran it under debian etch.
>
> Unfortunately, both the client and server machines panic (actually I'm
> using qemu to make things easy for myself).  Although my test programs
> might be buggy, I don't believe they should cause a panic.
>
> Has anyone got this stuff working yet?

This seems bogus to me :-

struct tcp_md5sig_pool *__tcp_get_md5sig_pool(int cpu)
{
        struct tcp_md5sig_pool **p;
        spin_lock(&tcp_md5sig_pool_lock);
        p = tcp_md5sig_pool;
        if (p)
                tcp_md5sig_users++;
        spin_unlock(&tcp_md5sig_pool_lock);
        return (p ? *per_cpu_ptr(p, cpu) : NULL);
}

void __tcp_put_md5sig_pool(void) {
        __tcp_free_md5sig_pool(tcp_md5sig_pool);
}

Certainly commenting out the body of __tcp_put_md5sig_pool gets things
working.

I'm not sure what the correct way forward is.  Could these functions
not be just:

struct tcp_md5sig_pool *__tcp_get_md5sig_pool(int cpu)
{
        struct tcp_md5sig_pool **p = tcp_md5_sig_pool;
	BUG_ON(!p);
	return *per_cpu_ptr(p, cpu);
}

void __tcp_put_md5sig_pool(void) {
        /* nuffin */
}

In other words, can we assume that the pool is allocated when we call
tcp_get_md5sig_pool?

Thanks,

Leigh.

