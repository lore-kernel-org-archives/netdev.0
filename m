From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V3 4/6] vhost_net: determine whether or not to use zerocopy
	at one time
Date: Thu, 26 Sep 2013 12:30:17 +0800
Message-ID: <5243B859.3070302@redhat.com>
References: <1378111261-14826-1-git-send-email-jasowang@redhat.com>
	<1378111261-14826-5-git-send-email-jasowang@redhat.com>
	<20130904115929.GA9393@redhat.com> <5227F274.9040506@redhat.com>
	<20130923071620.GB31886@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130923071620.GB31886@redhat.com>
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

On 09/23/2013 03:16 PM, Michael S. Tsirkin wrote:
> On Thu, Sep 05, 2013 at 10:54:44AM +0800, Jason Wang wrote:
>> > On 09/04/2013 07:59 PM, Michael S. Tsirkin wrote:
>>> > > On Mon, Sep 02, 2013 at 04:40:59PM +0800, Jason Wang wrote:
>>>> > >> Currently, even if the packet length is smaller than VHOST_GOODCOPY_LEN, if
>>>> > >> upend_idx != done_idx we still set zcopy_used to true and rollback this choice
>>>> > >> later. This could be avoided by determining zerocopy once by checking all
>>>> > >> conditions at one time before.
>>>> > >>
>>>> > >> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>>> > >> ---
>>>> > >>  drivers/vhost/net.c |   47 ++++++++++++++++++++---------------------------
>>>> > >>  1 files changed, 20 insertions(+), 27 deletions(-)
>>>> > >>
>>>> > >> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>>>> > >> index 8a6dd0d..3f89dea 100644
>>>> > >> --- a/drivers/vhost/net.c
>>>> > >> +++ b/drivers/vhost/net.c
>>>> > >> @@ -404,43 +404,36 @@ static void handle_tx(struct vhost_net *net)
>>>> > >>  			       iov_length(nvq->hdr, s), hdr_size);
>>>> > >>  			break;
>>>> > >>  		}
>>>> > >> -		zcopy_used = zcopy && (len >= VHOST_GOODCOPY_LEN ||
>>>> > >> -				       nvq->upend_idx != nvq->done_idx);
>>>> > >> +
>>>> > >> +		zcopy_used = zcopy && len >= VHOST_GOODCOPY_LEN
>>>> > >> +				   && (nvq->upend_idx + 1) % UIO_MAXIOV !=
>>>> > >> +				      nvq->done_idx
>>> > > Thinking about this, this looks strange.
>>> > > The original idea was that once we start doing zcopy, we keep
>>> > > using the heads ring even for short packets until no zcopy is outstanding.
>> > 
>> > What's the reason for keep using the heads ring?
> To keep completions in order.

Ok, I will do some test to see the impact.
>>> > >
>>> > > What's the logic behind (nvq->upend_idx + 1) % UIO_MAXIOV != nvq->done_idx
>>> > > here?
>> > 
>> > Because we initialize both upend_idx and done_idx to zero, so upend_idx
>> > != done_idx could not be used to check whether or not the heads ring
>> > were full.
> But what does ring full have to do with zerocopy use?
>

It was used to forbid the zerocopy when heads ring are full, but since
we have the limitation now, it could be removed.
