From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 3/3] net: auto-tune mergeable rx buffer size for
	improved performance
Date: Wed, 8 Jan 2014 19:37:53 +0200
Message-ID: <20140108173753.GE17404@redhat.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<1387239389-13216-3-git-send-email-mwdalton@google.com>
	<52BBDBAD.8030609@redhat.com>
	<CANJ5vPJX1yTKJXpFe+PO7u89-tYRjNPdJwrBLjAop3veye1pDg@mail.gmail.com>
	<52BCEE4E.7070106@redhat.com>
	<CANJ5vPJdHPkmz1DpmsULXjcXvToOox4cgjadKvc_HCKws=CGzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CANJ5vPJdHPkmz1DpmsULXjcXvToOox4cgjadKvc_HCKws=CGzw@mail.gmail.com>
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

On Fri, Dec 27, 2013 at 01:41:28PM -0800, Michael Dalton wrote:
> I'm working on a followup patchset to address current feedback. I think
> it will be cleaner to do a debugfs implementation for per-receive queue
> packet buffer size exporting, so I'm trying that out.
> 
> On Thu, Dec 26, 2013 at 7:04 PM, Jason Wang <jasowang@redhat.com> wrote:
> > We can make this more accurate by using extra data structure to track
> > the real buf size and using it as token.
> 
> I agree -- we can do precise buffer total len tracking. Something like
> struct mergeable_packet_buffer_ctx {
>    void *buf;
>    unsigned int total_len;

Maybe make total_len long so size is a power of 2.

> };

Hmm this doubles VQ cache footprint.
In the past when I tried increasong cache footprint
this hurt performance measureable. It's just a suggestion though,
YMMV, if numbers are good we don't need to argue about this.

> 
> Each receive queue could have a pointer to an array of N buffer contexts,
> where N is queue size (kzalloc'd in init_vqs or similar). That would
> allow us to allocate all of our buffer context data at startup.
> 
> Would this be preferred to the current approach or is there another
> approach you would prefer? All other things being equal, having precise
> length tracking is advantageous, so I'm inclined to try this out and
> see how it goes.
> 
> I think this is a big design point - for example, if we have an extra
> buffer context structure, then per-receive queue frag allocators are not
> required for auto-tuning and we can reduce the number of patches in
> this patchset.

I'd be careful with adding even more stuff in
mergeable_packet_buffer_ctx for above reason.

> I'm happy to implement either way.  Thanks!
> 
> Best,
> 
> Mike
