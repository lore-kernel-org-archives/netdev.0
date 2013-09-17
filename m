From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost/scsi: use vmalloc for order-10 allocation
Date: Tue, 17 Sep 2013 22:51:54 +0300
Message-ID: <20130917195154.GC21419@redhat.com>
References: <1379401998-5131-1-git-send-email-mst@redhat.com>
	<52389C0D.7070307@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Dan Aloni <alonid@stratoscale.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <52389C0D.7070307@cogentembedded.com>
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

On Tue, Sep 17, 2013 at 10:14:37PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 09/17/2013 11:21 AM, Michael S. Tsirkin wrote:
> 
> >As vhost scsi device struct is large, if the device is
> >created on a busy system, kzalloc() might fail, so this patch does a
> >fallback to vzalloc().
> 
> >As vmalloc() adds overhead on data-path, add __GFP_REPEAT
> >to kzalloc() flags to do this fallback only when really needed.
> 
> >Reported-by: Dan Aloni <alonid@stratoscale.com>
> >Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >---
> 
> >I put this on my vhost fixes branch, intend to merge for 3.12.
> >Dan, could you please confirm this works for you?
> 
> >  drivers/vhost/scsi.c | 41 +++++++++++++++++++++++++++--------------
> >  1 file changed, 27 insertions(+), 14 deletions(-)
> 
> >diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
> >index 4b79a1f..2c30bb0 100644
> >--- a/drivers/vhost/scsi.c
> >+++ b/drivers/vhost/scsi.c
> >@@ -1373,21 +1373,30 @@ static int vhost_scsi_set_features(struct vhost_scsi *vs, u64 features)
> >  	return 0;
> >  }
> >
> >+static void vhost_scsi_free(struct vhost_scsi *vs)
> >+{
> >+        if (is_vmalloc_addr(vs))
> >+                vfree(vs);
> >+        else
> >+                kfree(vs);
> 
>    Indent with the tabs ISO spaces, please.
> 
> >+}
> >+
> >  static int vhost_scsi_open(struct inode *inode, struct file *f)
> >  {
> >  	struct vhost_scsi *vs;
> >  	struct vhost_virtqueue **vqs;
> >-	int r, i;
> >+	int r = -ENOMEM, i;
> >
> >-	vs = kzalloc(sizeof(*vs), GFP_KERNEL);
> >-	if (!vs)
> >-		return -ENOMEM;
> >+        vs = kzalloc(sizeof(*vs), GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
> 
>    Indent here with a tab, please.
> 
> >+	if (!vs) {
> >+		vs = vzalloc(sizeof(*vs));
> >+		if (!vs)
> >+			goto err_vs;
> >+	}
> 
> WBR, Sergei

Thanks, I'll fix this up.
