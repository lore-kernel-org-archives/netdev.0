From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH RFC] pkt_sched: QFQ Plus: fair-queueing service at DRR
 cost
Date: Mon, 1 Oct 2012 14:36:48 -0700
Message-ID: <20121001143648.0dcf01ea@nehalam.linuxnetplumber.net>
References: <20120930174049.GA13793@paolo-ThinkPad-W520>
	<20121001083100.13fc231c@nehalam.linuxnetplumber.net>
	<5069D701.9090403@unimore.it>
	<20121001105206.71d16488@nehalam.linuxnetplumber.net>
	<B6AF212A-AF60-44AE-8FE9-B8C561D9898D@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rizzo@iet.unipi.it, fchecconi@gmail.com
To: Paolo Valente <paolo.valente@unimore.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <B6AF212A-AF60-44AE-8FE9-B8C561D9898D@unimore.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 1 Oct 2012 23:31:44 +0200
Paolo Valente <paolo.valente@unimore.it> wrote:

> 
> Il giorno 01/ott/2012, alle ore 19:52, Stephen Hemminger ha scritto:
> 
> > On Mon, 01 Oct 2012 19:46:41 +0200
> > Paolo Valente <paolo.valente@unimore.it> wrote:
> > 
> >> Il 01/10/2012 17:31, Stephen Hemminger ha scritto:
> >>> On Sun, 30 Sep 2012 19:40:49 +0200
> >>> Paolo Valente <paolo.valente@unimore.it> wrote:
> >>> 
> >>>> Hi,
> >>>> this patch turns QFQ into QFQ+, a faster variant of QFQ that groups
> >>>> classes into aggregates, and uses the original QFQ scheduling
> >>>> algorithm to schedule aggregates instead of single classes. An
> >>>> aggregate is made of at most M classes, all with the same weight and
> >>>> maximum packet size.  M is equal to the minimum between tx_queue_len+1
> >>>> and 8 (value chosen to get a good trade-off between execution time and
> >>>> service guarantees). QFQ+ associates each aggregate with a budget
> >>>> equal to the maximum packet size for the classes in the aggregate,
> >>>> multiplied by the number of classes of the aggregate. Once selected an
> >>>> aggregate for service, QFQ+ dequeues only the packets of its classes,
> >>>> until the aggregate finishes its budget. Finally, within an aggregate,
> >>>> classes are scheduled with DRR. In my tests, described below, the
> >>>> execution time of QFQ+ with M=8 was from 16% to 31% lower than that of
> >>>> QFQ, and close to that of DRR.
> >>>> 
> >>>> QFQ+ does not use packet lengths for computing aggregate timestamps,
> >>>> but budgets. Hence it does not need to modify any timestamp if the
> >>>> head packet of a class changes. As a consequence, differently from
> >>>> QFQ, which uses head-packet lengths to compute class timestamps, QFQ+
> >>>> does not need further modifications to correctly schedule also
> >>>> non-leaf classes and classes with non-FIFO qdiscs. Finally, QFQ+ is
> >>>> more robust than QFQ against corruption of the data structures
> >>>> implementing the bucket lists. A detailed description of QFQ+ can be
> >>>> found in [1].
> >>>> 
> >>>> As for service guarantees, thanks to the way how M is computed, the
> >>>> service of QFQ+ is close to the one of QFQ. For example, as proved in
> >>>> [1], under QFQ+ every packet of a given class is guaranteed the same
> >>>> worst-case completion time as under QFQ, plus an additional delay
> >>>> equal to the transmission time, at the rate reserved to the class, of
> >>>> three maximum-size packet. See [1, Section 7.1] for a numerical
> >>>> comparison among the packet delays guaranteed by QFQ+, QFQ and DRR.
> >>>> 
> >>>> I measured the execution time of QFQ+, DRR and QFQ using the testing
> >>>> environment [2]. In particular, for each scheduler I measured the
> >>>> average total execution time of a packet enqueue plus a packet
> >>>> dequeue.  For practical reasons, in this testing environment each
> >>>> enqueue&dequeue is also charged for the cost of generating and
> >>>> discarding an empty, fixed-size packet (using a free list). The
> >>>> following table reports the results with an i7-2760QM, against four
> >>>> different class sets. Time is measured in nanoseconds, while each set
> >>>> or subset of classes is denoted as <num_classes>-w<weight>, where
> >>>> <num_classes> and <weight> are, respectively, the number of classes
> >>>> and the weight of every class in the set/subset (for example, 250-w1
> >>>> stands for 250 classes with weight 1). For QFQ+, the table shows the
> >>>> results for the two extremes for M: 1 and 8 (see [1, Section 7.2] for
> >>>> results with other values of M and for more information).
> >>>> 
> >>>>  -----------------------------------------------
> >>>> | Set of  |      QFQ+ (M)     |   DRR      QFQ  |
> >>>> | classes |    1          8   |                 |
> >>>> |-----------------------------------------------|
> >>>> | 1k-w1   |   89         63   |    56       81  |
> >>>> |-----------------------------------------------|
> >>>> | 500-w1, |                   |                 |
> >>>> | 250-w2, |  102         71   |    87      103  |
> >>>> | 250-w4  |                   |                 |
> >>>> |-----------------------------------------------|
> >>>> | 32k-w1  |  267        225   |   173      257  |
> >>>> |-----------------------------------------------|
> >>>> | 16k-w1, |                   |                 |
> >>>> | 8k-w2,  |  253        187   |   252      257  |
> >>>> | 8k-w4   |                   |                 |
> >>>>  -----------------------------------------------
> >>>> 
> >>>> About DRR, it achieves its best performance when all the classes have
> >>>> the same weight. This is fortunate, because in such scenarios it is
> >>>> actually pointless to use a fair-queueing scheduler, as the latter
> >>>> would provide the same quality of service as DRR. In contrast, when
> >>>> classes have differentiated weights and the better service properties
> >>>> of QFQ+ make a difference, QFQ+ has better performance than DRR. It
> >>>> happens mainly because QFQ+ dequeues packets in an order that causes
> >>>> about 8% less cache misses than DRR. As for the number of
> >>>> instructions, QFQ+ executes instead about 7% more instructions than
> >>>> DRR, whereas QFQ executes from 25% to 34% more instructions than DRR.
> >>>> 
> >>>> Paolo
> >>>> 
> >>>> [1] P. Valente, "Reducing the Execution Time of Fair-Queueing Schedulers"
> >>>> http://algo.ing.unimo.it/people/paolo/agg-sched/agg-sched.pdf
> >>>> 
> >>>> [2] http://algo.ing.unimo.it/people/paolo/agg-sched/test-env.tgz
> >>>> 
> >>>> Signed-off-by: Paolo Valente <paolo.valente@unimore.it>
> >>> I like the improvement and the performance improvement.
> >>> Is there some concern that changing the implementation this much might
> >>> upset some people already using QFQ?
> >> If you mean people upset for the degradation of the service quality 
> >> (which should however be hard to perceive in most practical 
> >> applications), then the following solution could address this issue. It 
> >> was the my first idea, before I decided not to change the interface at all.
> >> 
> >> 1. Add an additional parameter M to the tc interface, with two types of 
> >> values:
> >> 0        -> automatically compute the max number of classes in an 
> >> aggregate using the current formula
> >>> 0     -> use the value provided by the user as max number of classes
> >> 
> >> 2. Set M to 1 as default value, which would let QFQ+ behave as QFQ by 
> >> default.
> >> 
> >> tc should however be modified, and people using QFQ should probably move 
> >> to the new version (which is the main reason why I opted for the other 
> >> solution).
> >> 
> >> Paolo
> >>> What happens if an existing working QFQ config is used in QFQ+?
> >>> 
> >>> 
> >>> 
> >> 
> >> 
> > 
> > In order for the transistion to be seamless all possible upgrades
> > have to work. As in:
> >  * old iproute2 utilities with new kernel with QFQ+
> >  * new iproute2 utilities with old kernel with QFQ
> > 
> > It is okay to force users to give new parameters to get full performance,
> > but just don't want to break existing users.
> 
> I am sorry for asking again, but I did not clearly understand what you think about the current solution, with no interface change, no need to give new parameters, and no compatibility issues between new and old versions of iproute2 and kernel. But of course with less control over the small service deviation between QFQ+ and QFQ.
> 

Then great, I say put it in for net-next.
