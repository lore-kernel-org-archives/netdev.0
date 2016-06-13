From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [very-RFC 6/8] Add TSN event-tracing
Date: Sun, 12 Jun 2016 22:22:01 -0400
Message-ID: <20160612222201.00a8aa4c@grimm.local.home>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <1465686096-22156-7-git-send-email-henrik@austad.us>
 <20160612125803.27f401cc@gandalf.local.home>
 <20160612212510.GD32724@icarus.home.austad.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 "David S. Miller" <davem@davemloft.net>, Ingo Molnar <mingo@redhat.com>,
 Henrik Austad <haustad@cisco.com>, alsa-devel@vger.kernel.org,
 linux-media@vger.kernel.org
To: alsa-devel@alsa-project.org
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20160612212510.GD32724@icarus.home.austad.us>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

On Sun, 12 Jun 2016 23:25:10 +0200
Henrik Austad <henrik@austad.us> wrote:

> > > +#include <linux/if_ether.h>
> > > +#include <linux/if_vlan.h>
> > > +/* #include <linux/skbuff.h> */
> > > +
> > > +/* FIXME: update to TRACE_CLASS to reduce overhead */  
> > 
> > I'm curious to why I didn't do this now. A class would make less
> > duplication of typing too ;-)  
> 
> Yeah, I found this in a really great article written by some tracing-dude, 
> I hear he talks really, really fast!

I plead the 5th!

> 
> https://lwn.net/Articles/381064/
> 
> > > +TRACE_EVENT(tsn_buffer_write,
> > > +
> > > +	TP_PROTO(struct tsn_link *link,
> > > +		size_t bytes),
> > > +
> > > +	TP_ARGS(link, bytes),
> > > +
> > > +	TP_STRUCT__entry(
> > > +		__field(u64, stream_id)
> > > +		__field(size_t, size)
> > > +		__field(size_t, bsize)
> > > +		__field(size_t, size_left)
> > > +		__field(void *, buffer)
> > > +		__field(void *, head)
> > > +		__field(void *, tail)
> > > +		__field(void *, end)
> > > +		),
> > > +
> > > +	TP_fast_assign(
> > > +		__entry->stream_id = link->stream_id;
> > > +		__entry->size = bytes;
> > > +		__entry->bsize = link->used_buffer_size;
> > > +		__entry->size_left = (link->head - link->tail) % link->used_buffer_size;  
> > 
> > Move this logic into the print statement, since you save head and tail.  
> 
> Ok, any particular reason?

Because it removes calculations during the trace. The calculations done
in TP_printk() are done at the time of reading the trace, and
calculations done in TP_fast_assign() are done during the recording and
hence adding more overhead to the trace itself.


> 
> > > +		__entry->buffer = link->buffer;
> > > +		__entry->head = link->head;
> > > +		__entry->tail = link->tail;
> > > +		__entry->end = link->end;
> > > +		),
> > > +
> > > +	TP_printk("stream_id=%llu, copy=%zd, buffer: %zd, avail=%zd, [buffer=%p, head=%p, tail=%p, end=%p]",
> > > +		__entry->stream_id, __entry->size, __entry->bsize, __entry->size_left,  
> > 
> >  __entry->stream_id, __entry->size, __entry->bsize,
> >  (__entry->head - __entry->tail) % __entry->bsize,
> >   
> 
> Ok, so is this about saving space by dropping one intermediate value, or is 
> it some other point I'm missing here?

Nope, just moving the overhead from the recording of the trace to the
reading of the trace.

> 
> > > +		__entry->buffer,    __entry->head, __entry->tail,  __entry->end)
> > > +
> > > +	);
> > > +


> > > +
> > > +	TP_fast_assign(
> > > +		__entry->stream_id = link->stream_id;
> > > +		__entry->vlan_tag = (skb_vlan_tag_present(skb) ? skb_vlan_tag_get(skb) : 0);
> > > +		__entry->bytes = bytes;
> > > +		__entry->data_len = skb->data_len;
> > > +		__entry->headlen = skb_headlen(skb);
> > > +		__entry->protocol = ntohs(vlan_get_protocol(skb));  
> > 
> > Maybe it would be better to do the ntohs() in the TP_printk() as well.
> >   
> > > +		__entry->prot_native = ntohs(skb->protocol);  
> > 
> > here too.
> >   
> > > +		__entry->tx_idx = skb_get_queue_mapping(skb);
> > > +
> > > +		__entry->mac_len = skb->mac_len;
> > > +		__entry->hdr_len = skb->hdr_len;
> > > +		__entry->vlan_tci = skb->vlan_tci;
> > > +		__entry->mac_header = skb->mac_header;
> > > +		__entry->tail = (unsigned int)skb->tail;
> > > +		__entry->end  = (unsigned int)skb->end;
> > > +		__entry->truesize = skb->truesize;
> > > +		),
> > > +
> > > +	TP_printk("stream_id=%llu,vlan_tag=0x%04x,data_size=%zd,data_len=%zd,headlen=%u,proto=0x%04x (0x%04x),tx_idx=%d,mac_len=%u,hdr_len=%u,vlan_tci=0x%02x,mac_header=0x%02x,tail=%u,end=%u,truesize=%u",
> > > +		__entry->stream_id,
> > > +		__entry->vlan_tag,
> > > +		__entry->bytes,
> > > +		__entry->data_len,
> > > +		__entry->headlen,
> > > +		__entry->protocol,
> > > +		__entry->prot_native, __entry->tx_idx,
> > > +		__entry->mac_len,
> > > +		__entry->hdr_len,
> > > +		__entry->vlan_tci,
> > > +		__entry->mac_header,  
> > 
> > Is this an ether mac header? If so we support %M. But as it's defined
> > as only u16, it doesn't seem like it can be.  
> 
> Actually, looking at the output, I'm not quite sure what it is that I 
> wanted to grab with that, the skb->mac_header should give an offset into 
> the header-area of skb, so it should be a constant offset from skb->head 
> (that is an actual pointer).
> 
> I *think* I wanted to make sure I updated things correctly so that the 
> offset didn't suddenly change, but the fact that I'm no longer sure 
> indicates that I should just drop that one. That whole printout is too long 
> anyway..
> 
> Thanks for pointing a finger at this!
> 
> 
> I'm still a bit stymied as to why logic should be in TP_printk() and not 
> TP_fast_assign(). Not that I really have any preferences either way, just 
> curious.

As said above, it's simply just trying to make tracing have less of an
effect on what is being traced. The more you can do in the post
transactions the faster the trace becomes and less invasive the trace
is on the system performance.

-- Steve

--
To unsubscribe from this list: send the line "unsubscribe alsa-devel" in
