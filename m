From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PULL 2/2] vhost: replace rcu with mutex
Date: Tue, 03 Jun 2014 06:57:43 -0700
Message-ID: <1401803863.3645.208.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401744482-17764-1-git-send-email-mst@redhat.com>
	<1401744482-17764-3-git-send-email-mst@redhat.com>
	<1401746280.3645.187.camel@edumazet-glaptop2.roam.corp.google.com>
	<538DC422.1050303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Paolo Bonzini <pbonzini@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <538DC422.1050303@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-06-03 at 14:48 +0200, Paolo Bonzini wrote:
> Il 02/06/2014 23:58, Eric Dumazet ha scritto:
> > This looks dubious
> >
> > What about using kfree_rcu() instead ?
> 
> It would lead to unbound allocation from userspace.

Look at how we did this in commit
c3059477fce2d956a0bb3e04357324780c5d8eeb

> 
> > translate_desc() still uses rcu_read_lock(), its not clear if the mutex
> > is really held.
> 
> Yes, vhost_get_vq_desc must be called with the vq mutex held.
> 
> The rcu_read_lock/unlock in translate_desc is unnecessary.

Yep, this is what I pointed out. This is not only necessary, but
confusing and might be incorrectly copy/pasted in the future.

This patch is a partial one and leaves confusion.

Some places uses the proper 

mp = rcu_dereference_protected(dev->memory,
		 lockdep_is_held(&dev->mutex));

others use the now incorrect :

rcu_read_lock();
mp = rcu_dereference(dev->memory);
...
