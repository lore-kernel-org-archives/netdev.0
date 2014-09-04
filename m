From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 3/3] virtio_ring: unify direct/indirect code paths.
Date: Wed, 3 Sep 2014 18:59:33 -0700
Message-ID: <CALCETrVCR+Zm9RtF7gGmO-XcMAb4fLsxKMG-aEABqhbywF9+Jw@mail.gmail.com>
References: <1409718556-3041-1-git-send-email-rusty@rustcorp.com.au>
	<1409718556-3041-4-git-send-email-rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Linux Virtualization <virtualization@lists.linux-foundation.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1409718556-3041-4-git-send-email-rusty@rustcorp.com.au>
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

On Tue, Sep 2, 2014 at 9:29 PM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> virtqueue_add() populates the virtqueue descriptor table from the sgs
> given.  If it uses an indirect descriptor table, then it puts a single
> descriptor in the descriptor table pointing to the kmalloc'ed indirect
> table where the sg is populated.
>
> Previously vring_add_indirect() did the allocation and the simple
> linear layout.  We replace that with alloc_indirect() which allocates
> the indirect table then chains it like the normal descriptor table so
> we can reuse the core logic.
>

> +       if (vq->indirect && total_sg > 1 && vq->vq.num_free)
> +               desc = alloc_indirect(total_sg, gfp);
> +       else
> +               desc = NULL;
> +
> +       if (desc) {
> +               /* Use a single buffer which doesn't continue */
> +               vq->vring.desc[head].flags = VRING_DESC_F_INDIRECT;
> +               vq->vring.desc[head].addr = virt_to_phys(desc);
> +               /* avoid kmemleak false positive (hidden by virt_to_phys) */
> +               kmemleak_ignore(desc);
> +               vq->vring.desc[head].len = total_sg * sizeof(struct vring_desc);
> +
> +               /* Set up rest to use this indirect table. */
> +               i = 0;
> +               total_sg = 1;

This is a little too magical for me.  Would it make sense to add a new
variable for this (total_root_descs or something)?

--Andy
