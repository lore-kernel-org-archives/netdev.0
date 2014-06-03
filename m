From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PULL 2/2] vhost: replace rcu with mutex
Date: Tue, 03 Jun 2014 15:55:45 +0200
Message-ID: <538DD3E1.8000805@redhat.com>
References: <1401744482-17764-1-git-send-email-mst@redhat.com>	<1401744482-17764-3-git-send-email-mst@redhat.com>
	<1401746280.3645.187.camel@edumazet-glaptop2.roam.corp.google.com>
	<538DC422.1050303@redhat.com> <538DCF15.4080904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Vlad Yasevich <vyasevich@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <538DCF15.4080904@gmail.com>
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

Il 03/06/2014 15:35, Vlad Yasevich ha scritto:
> > Yes, vhost_get_vq_desc must be called with the vq mutex held.
> >
> > The rcu_read_lock/unlock in translate_desc is unnecessary.
>
> If that's true, then does dev->memory really needs to be rcu protected?
> It appears to always be read under mutex.

It's always read under one of many mutexes, yes.

However, it's still RCU-like in the sense that you separate the removal 
and reclamation phases so you still need rcu_dereference/rcu_assign_pointer.

With this mechanism, readers do not contend the mutexes with the 
VHOST_SET_MEMORY ioctl, except for the very short lock-and-unlock 
sequence at the end of it.  They also never contend the mutexes between 
themselves (which would be the case if VHOST_SET_MEMORY locked all the 
mutexes).

You could also wrap all virtqueue processing with a rwsem and take the 
rwsem for write in VHOST_SET_MEMORY.  That simplifies some things however:

- unnecessarily complicates the code for all users of vhost_get_vq_desc

- suppose the reader-writer lock is fair, and VHOST_SET_MEMORY places a 
writer in the queue.  Then a long-running reader R1 could still block 
another reader R2, because the writer would be served before R2.


The RCU-like approach avoids all this, which is important because of the 
generally simpler code and because VHOST_SET_MEMORY is the only vhost 
ioctl that can happen in the hot path.

Paolo
