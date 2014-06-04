From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PULL 2/2] vhost: replace rcu with mutex
Date: Wed, 4 Jun 2014 21:12:57 +0300
Message-ID: <20140604181257.GA11756@redhat.com>
References: <1401744482-17764-1-git-send-email-mst@redhat.com>
	<1401744482-17764-3-git-send-email-mst@redhat.com>
	<1401746280.3645.187.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1401746280.3645.187.camel@edumazet-glaptop2.roam.corp.google.com>
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

On Mon, Jun 02, 2014 at 02:58:00PM -0700, Eric Dumazet wrote:
> On Tue, 2014-06-03 at 00:30 +0300, Michael S. Tsirkin wrote:
> > All memory accesses are done under some VQ mutex.
> > So lock/unlock all VQs is a faster equivalent of synchronize_rcu()
> > for memory access changes.
> > Some guests cause a lot of these changes, so it's helpful
> > to make them faster.
> > 
> > Reported-by: "Gonglei (Arei)" <arei.gonglei@huawei.com>
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> >  drivers/vhost/vhost.c | 10 +++++++++-
> >  1 file changed, 9 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > index 78987e4..1c05e60 100644
> > --- a/drivers/vhost/vhost.c
> > +++ b/drivers/vhost/vhost.c
> > @@ -593,6 +593,7 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
> >  {
> >  	struct vhost_memory mem, *newmem, *oldmem;
> >  	unsigned long size = offsetof(struct vhost_memory, regions);
> > +	int i;
> >  
> >  	if (copy_from_user(&mem, m, size))
> >  		return -EFAULT;
> > @@ -619,7 +620,14 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
> >  	oldmem = rcu_dereference_protected(d->memory,
> >  					   lockdep_is_held(&d->mutex));
> >  	rcu_assign_pointer(d->memory, newmem);
> > -	synchronize_rcu();
> > +
> > +	/* All memory accesses are done under some VQ mutex.
> > +	 * So below is a faster equivalent of synchronize_rcu()
> > +	 */
> > +	for (i = 0; i < d->nvqs; ++i) {
> > +		mutex_lock(&d->vqs[i]->mutex);
> > +		mutex_unlock(&d->vqs[i]->mutex);
> > +	}
> >  	kfree(oldmem);
> >  	return 0;
> >  }
> 
> This looks dubious
> 
> What about using kfree_rcu() instead ?

Unfortunately userspace relies on the fact that no one
uses the old mappings by the time ioctl returns.
The issue isn't freeing the memory.

> translate_desc() still uses rcu_read_lock(), its not clear if the mutex
> is really held.
> 

Thanks, good point, we can drop that rcu_read_lock now, but I think this could be a
patch on top.

-- 
MST
