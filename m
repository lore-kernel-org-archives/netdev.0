From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.2 crash after network link failure
Date: Mon, 9 Feb 2004 14:28:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209142842.508ee3b7.davem@redhat.com>
References: <20040209130134.GA14136@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, scott.feldman@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Petr Vandrovec <vandrove@vc.cvut.cz>
In-Reply-To: <20040209130134.GA14136@vana.vc.cvut.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 9 Feb 2004 14:01:34 +0100
Petr Vandrovec <vandrove@vc.cvut.cz> wrote:

> It looks to me like that we've got skb on completion_queue which was connected
> to a bit unhappy socket - one which had sk->sk_sleep uninitialized. Only problem 
> is that only af_unix sets skb->destructor to sock_wfree, so I somehow miss how 
> this could be triggered by e100 link change.

It is not only af_unix, any time we invoke skb_set_owner_w() we get sock_wfree()
as the destructor, furthermore sock_def_write_space is the default such handler
given to all sockets unless they override that.

Maybe e100 is mangling it's TX queue or in fact freeing things twice.

I think what might be happening is that somehow the TX queue is corrupted if
e100_config() runs (due to link UP state change) while there are active normal
SKB packets on the TX queue.  Or perhaps some TX queue handling locking issue.

Scott, any ideas?
