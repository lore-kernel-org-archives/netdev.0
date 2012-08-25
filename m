From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH 6/8] csiostor: Chelsio FCoE offload driver submission
 (headers part 1).
Date: Sat, 25 Aug 2012 11:40:29 -0700
Message-ID: <1345920029.28432.102.camel@haakon2.linux-iscsi.org>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com>
	 <1345760873-12101-7-git-send-email-naresh@chelsio.com>
	 <1345751929.10190.83.camel@haakon2.linux-iscsi.org>
	 <5037C997.4030803@chelsio.com>
	 <1345843042.28432.65.camel@haakon2.linux-iscsi.org>
	 <503914C4.4050600@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "JBottomley@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: Naresh Kumar Inna <naresh@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <503914C4.4050600@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-08-25 at 23:39 +0530, Naresh Kumar Inna wrote:
> On 8/25/2012 2:47 AM, Nicholas A. Bellinger wrote:
> > On Sat, 2012-08-25 at 00:06 +0530, Naresh Kumar Inna wrote:
> >> On 8/24/2012 1:28 AM, Nicholas A. Bellinger wrote:
> >>> On Fri, 2012-08-24 at 03:57 +0530, Naresh Kumar Inna wrote:
> >>>> This patch contains the first set of the header files for csiostor driver.
> >>>>
> >>>> Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
> >>>> ---
> >>>>  drivers/scsi/csiostor/csio_defs.h       |  143 ++++++
> >>>>  drivers/scsi/csiostor/csio_fcoe_proto.h |  843 +++++++++++++++++++++++++++++++
> >>>>  drivers/scsi/csiostor/csio_hw.h         |  668 ++++++++++++++++++++++++
> >>>>  drivers/scsi/csiostor/csio_init.h       |  158 ++++++
> >>>>  4 files changed, 1812 insertions(+), 0 deletions(-)
> >>>>  create mode 100644 drivers/scsi/csiostor/csio_defs.h
> >>>>  create mode 100644 drivers/scsi/csiostor/csio_fcoe_proto.h
> >>>>  create mode 100644 drivers/scsi/csiostor/csio_hw.h
> >>>>  create mode 100644 drivers/scsi/csiostor/csio_init.h
> >>>>
> >>>
> >>> Hi Naresh,
> >>>
> >>> Just commenting on csio_defs.h bits here...  As Robert mentioned, you'll
> >>> need to convert the driver to use (or add to) upstream protocol
> >>> definitions and drop the csio_fcoe_proto.h bits..
> >>>
> >>
> >> Hi Nicholas,
> >>
> >> I would like take up the discussion of the protocol header file in that
> >> email thread. Please find the rest of my replies inline.
> >>
> >> Thanks for reviewing,
> >> Naresh.
> >>
> >>>> diff --git a/drivers/scsi/csiostor/csio_defs.h b/drivers/scsi/csiostor/csio_defs.h
> >>>> new file mode 100644
> >>>> index 0000000..4f1c713
> >>>> --- /dev/null
> >>>> +++ b/drivers/scsi/csiostor/csio_defs.h

<SNIP>

> >>>> +static inline int
> >>>> +csio_list_deleted(struct list_head *list)
> >>>> +{
> >>>> +	return ((list->next == list) && (list->prev == list));
> >>>> +}
> >>>> +
> >>>> +#define csio_list_next(elem)	(((struct list_head *)(elem))->next)
> >>>> +#define csio_list_prev(elem)	(((struct list_head *)(elem))->prev)
> >>>> +
> >>>> +#define csio_deq_from_head(head, elem)					  \
> >>>> +do {									  \
> >>>> +	if (!list_empty(head)) {					  \
> >>>> +		*((struct list_head **)(elem)) = csio_list_next((head));  \
> >>>> +		csio_list_next((head)) =				  \
> >>>> +				csio_list_next(csio_list_next((head)));   \
> >>>> +		csio_list_prev(csio_list_next((head))) = (head);	  \
> >>>> +		INIT_LIST_HEAD(*((struct list_head **)(elem)));	          \
> >>>> +	} else								  \
> >>>> +		*((struct list_head **)(elem)) = (struct list_head *)NULL;\
> >>>> +} while (0)
> >>>> +
> >>>
> >>> This code is confusing as hell..  Why can't you just use normal list.h
> >>> macros for this..?  
> >>
> >> I have not found an equivalent function in list.h that does the above
> >> and the following macro. Could you please point me to it? I have seen a
> >> couple of other drivers define their own macros to achieve what this
> >> macro does, hence I assumed there isnt a list.h macro that does this.
> >>
> > 
> > AFAICT all that csio_deq_from_head code is supposed to do is pull an
> > item off a list, right..?  Why not just:
> > 
> >      while (!list_empty(list)) {
> >             elem = list_first_entry(list, struct elem_type, 
> >                                     elm_list);
> >             list_del_init(&elem->elm_list);
> > 
> >             <do work>
> >             <free *elem memory>
> >      }
> >
> 
> I will try to come up with a simpler static inline version of the macro.
> Would that work?

No.  The point is that the above code is a disaster, and AFAICT there is
no reason why any of it is necessary to begin with at all.

Why can't csio_deq_from_head() just become list_first_entry() +
list_del_init() to do the exact same thing without all of the extra
overhead of list_head pointer de-reference + assignments..?

--nab

