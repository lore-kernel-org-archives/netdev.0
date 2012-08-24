From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH 6/8] csiostor: Chelsio FCoE offload driver submission
 (headers part 1).
Date: Fri, 24 Aug 2012 14:17:22 -0700
Message-ID: <1345843042.28432.65.camel@haakon2.linux-iscsi.org>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com>
	 <1345760873-12101-7-git-send-email-naresh@chelsio.com>
	 <1345751929.10190.83.camel@haakon2.linux-iscsi.org>
	 <5037C997.4030803@chelsio.com>
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
In-Reply-To: <5037C997.4030803@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-08-25 at 00:06 +0530, Naresh Kumar Inna wrote:
> On 8/24/2012 1:28 AM, Nicholas A. Bellinger wrote:
> > On Fri, 2012-08-24 at 03:57 +0530, Naresh Kumar Inna wrote:
> >> This patch contains the first set of the header files for csiostor driver.
> >>
> >> Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
> >> ---
> >>  drivers/scsi/csiostor/csio_defs.h       |  143 ++++++
> >>  drivers/scsi/csiostor/csio_fcoe_proto.h |  843 +++++++++++++++++++++++++++++++
> >>  drivers/scsi/csiostor/csio_hw.h         |  668 ++++++++++++++++++++++++
> >>  drivers/scsi/csiostor/csio_init.h       |  158 ++++++
> >>  4 files changed, 1812 insertions(+), 0 deletions(-)
> >>  create mode 100644 drivers/scsi/csiostor/csio_defs.h
> >>  create mode 100644 drivers/scsi/csiostor/csio_fcoe_proto.h
> >>  create mode 100644 drivers/scsi/csiostor/csio_hw.h
> >>  create mode 100644 drivers/scsi/csiostor/csio_init.h
> >>
> > 
> > Hi Naresh,
> > 
> > Just commenting on csio_defs.h bits here...  As Robert mentioned, you'll
> > need to convert the driver to use (or add to) upstream protocol
> > definitions and drop the csio_fcoe_proto.h bits..
> > 
> 
> Hi Nicholas,
> 
> I would like take up the discussion of the protocol header file in that
> email thread. Please find the rest of my replies inline.
> 
> Thanks for reviewing,
> Naresh.
> 
> >> diff --git a/drivers/scsi/csiostor/csio_defs.h b/drivers/scsi/csiostor/csio_defs.h
> >> new file mode 100644
> >> index 0000000..4f1c713
> >> --- /dev/null
> >> +++ b/drivers/scsi/csiostor/csio_defs.h

<SNIP>

> >> +#ifndef __CSIO_DEFS_H__
> >> +#define __CSIO_DEFS_H__
> >> +
> >> +#include <linux/kernel.h>
> >> +#include <linux/timer.h>
> >> +#include <linux/list.h>
> >> +#include <linux/bug.h>
> >> +#include <linux/pci.h>
> >> +#include <linux/jiffies.h>
> >> +
> >> +/* Function returns */
> >> +enum csio_retval {
> >> +	CSIO_SUCCESS = 0,
> >> +	CSIO_INVAL = 1,
> >> +	CSIO_BUSY = 2,
> >> +	CSIO_NOSUPP = 3,
> >> +	CSIO_TIMEOUT = 4,
> >> +	CSIO_NOMEM = 5,
> >> +	CSIO_NOPERM = 6,
> >> +	CSIO_RETRY = 7,
> >> +	CSIO_EPROTO = 8,
> >> +	CSIO_EIO = 9,
> >> +	CSIO_CANCELLED = 10,
> >> +};
> >> +
> > 
> > Please don't assign macros for errno's, and give them positive values.
> >
> 
> Although some of these return values appear to be mapped to errno
> values, there are others that do not have an errno equivalent (example
> CSIO_CANCELLED). We may have future needs to have more driver/protocol
> specific return values as well. What do you suggest?
> 

Convert all functions aside from CSIO_CANCELLED to use normal negative
return values from include/asm-generic/error[-base].h

For the CSIO_CANCELLED case, propagate this status up to the specific
caller using another method..

> >> +#define csio_retval_t enum csio_retval
> > 
> > Please get rid of this csio_retval_t nonsense.
> 
> I can get rid of the typedef and use enum csio_retval instead.
> 

Using a LLD defined retval where %90 of the items are from errno.h is
code duplication.  Please get rid of this.

> > 
> >> +
> >> +enum {
> >> +	CSIO_FALSE = 0,
> >> +	CSIO_TRUE = 1,
> >> +};
> >> +
> > 
> > Same here, please use normal Boolean macros
> > 
> >> +#define CSIO_ROUNDUP(__v, __r)		(((__v) + (__r) - 1) / (__r))
> >> +#define CSIO_INVALID_IDX		0xFFFFFFFF
> >> +#define csio_inc_stats(elem, val)	((elem)->stats.val++)
> >> +#define csio_dec_stats(elem, val)	((elem)->stats.val--)
> > 
> > No reason for either of this stats inc+dec macros.  Please drop them.
> 
> I will get rid of them.
> 
> > 
> >> +#define csio_valid_wwn(__n)		((*__n >> 4) == 0x5 ? CSIO_TRUE : \
> >> +						CSIO_FALSE)
> >> +#define CSIO_WORD_TO_BYTE		4
> >> +
> >> +static inline int
> >> +csio_list_deleted(struct list_head *list)
> >> +{
> >> +	return ((list->next == list) && (list->prev == list));
> >> +}
> >> +
> >> +#define csio_list_next(elem)	(((struct list_head *)(elem))->next)
> >> +#define csio_list_prev(elem)	(((struct list_head *)(elem))->prev)
> >> +
> >> +#define csio_deq_from_head(head, elem)					  \
> >> +do {									  \
> >> +	if (!list_empty(head)) {					  \
> >> +		*((struct list_head **)(elem)) = csio_list_next((head));  \
> >> +		csio_list_next((head)) =				  \
> >> +				csio_list_next(csio_list_next((head)));   \
> >> +		csio_list_prev(csio_list_next((head))) = (head);	  \
> >> +		INIT_LIST_HEAD(*((struct list_head **)(elem)));	          \
> >> +	} else								  \
> >> +		*((struct list_head **)(elem)) = (struct list_head *)NULL;\
> >> +} while (0)
> >> +
> > 
> > This code is confusing as hell..  Why can't you just use normal list.h
> > macros for this..?  
> 
> I have not found an equivalent function in list.h that does the above
> and the following macro. Could you please point me to it? I have seen a
> couple of other drivers define their own macros to achieve what this
> macro does, hence I assumed there isnt a list.h macro that does this.
> 

AFAICT all that csio_deq_from_head code is supposed to do is pull an
item off a list, right..?  Why not just:

     while (!list_empty(list)) {
            elem = list_first_entry(list, struct elem_type, 
                                    elm_list);
            list_del_init(&elem->elm_list);

            <do work>
            <free *elem memory>
     }

> >> +#define csio_deq_from_tail(head, elem)					  \
> >> +do {									  \
> >> +	if (!list_empty(head)) {					  \
> >> +		*((struct list_head **)(elem)) = csio_list_prev((head));  \
> >> +		csio_list_prev((head)) =				  \
> >> +				csio_list_prev(csio_list_prev((head)));	  \
> >> +		csio_list_next(csio_list_prev((head))) = (head);	  \
> >> +		INIT_LIST_HEAD(*((struct list_head **)(elem)));		  \
> >> +	} else								  \
> >> +		*((struct list_head **)(elem)) = (struct list_head *)NULL;\
> >> +} while (0)
> >> +
> > 
> > Same here..  Please don't use macros like this.
> >

AFIACT csio_deq_from_tail is unused..?

Please remove it..

