From: "Yan, Zheng" <ukernel@gmail.com>
Subject: Re: [PATCH 04/12] fs: ceph: CURRENT_TIME with ktime_get_real_ts()
Date: Fri, 2 Jun 2017 20:18:37 +0800
Message-ID: <CAAM7YA=f74Wye8hgqR52CNG-c4Sh3sm74AzZYhSnhjN1B=G-Ow@mail.gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
 <1491613030-11599-5-git-send-email-deepa.kernel@gmail.com>
 <CAAM7YAmp=cZKqGHa8UqDnrQLCe+6TKx+7w9SDZv4cW5fr4dfvA@mail.gmail.com>
 <CAK8P3a1pCw1Oo-Wg70kH5L12pbtEzGDfaPZ8g6ErERJjvY8znQ@mail.gmail.com>
 <CAAM7YAnWLUXMOCVbgfdKGfvK04EtAQcz-ETm7xFO=8Y=_fCvOQ@mail.gmail.com>
 <CALAqxLV-yVKWM5es7fAFiDzhSQmtZFiZDPQwBRUYbWUtqhoWVg@mail.gmail.com>
 <CABeXuvqvLr6sSGF+rZEXXxpCBDKTOeLX1ObSjbPPY4aFBuwvMg@mail.gmail.com>
 <CAAM7YAkXNo_69tOrw6a5kpyref9nEpEp-2vxBbFVSHGmAVbt+A@mail.gmail.com>
 <CAK8P3a1TwkVRCwDWqgYE8Z3wZT2+v6xayq=dVeW8KaHmO0W4cg@mail.gmail.com>
 <CAAM7YA=BJHFLz_Ud==7L=yCzxj+1sjctc68tvpNogPhiSxxELQ@mail.gmail.com>
 <CAK8P3a0D3EXuwBj+sSVL9cmpysdvQWXnkE0zEctBJS8XOqhX7A@mail.gmail.com>
 <CAAM7YAk8JNU=XV=sOCczagWjBimO4JSPU08th7E4u6FTJN--9A@mail.gmail.com> <CAK8P3a3m3nt6rfvAvDG6HFuUvy+qWbmk5K0UtLGqYhYHOfdF8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Deepa Dinamani <deepa.kernel@gmail.com>,
        John Stultz <john.stultz@linaro.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Al Viro <viro@zeniv.linux.org.uk>,
        gregkh <gregkh@linuxfoundation.org>,
        "Dilger, Andreas" <andreas.dilger@intel.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Chris Mason <clm@fb.com>,
        David Miller <davem@davemloft.net>,
        David Sterba <dsterba@suse.com>,
        Evgeniy Dushistov <dushistov@mail.ru>,
        Eric Paris <eparis@redhat.com>,
        Jaegeuk Kim <jaegeuk@kernel.org>, Josef Bacik <jbacik@fb.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        James Simmons <jsimmons@infradead.org>,
        Ingo Molnar <mingo@redhat.com>,
        "Drokin, Oleg" <oleg.drokin@intel.com>,
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a3m3nt6rfvAvDG6HFuUvy+qWbmk5K0UtLGqYhYHOfdF8w@mail.gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 2, 2017 at 7:33 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Fri, Jun 2, 2017 at 1:18 PM, Yan, Zheng <ukernel@gmail.com> wrote:
>> On Fri, Jun 2, 2017 at 6:51 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>>> On Fri, Jun 2, 2017 at 12:10 PM, Yan, Zheng <ukernel@gmail.com> wrote:
>>>> On Fri, Jun 2, 2017 at 5:45 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>>>>> On Fri, Jun 2, 2017 at 4:09 AM, Yan, Zheng <ukernel@gmail.com> wrote:
>>>>>> On Fri, Jun 2, 2017 at 8:57 AM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
>>>>>>> On Thu, Jun 1, 2017 at 5:36 PM, John Stultz <john.stultz@linaro.org> wrote:
>>>>>>>> On Thu, Jun 1, 2017 at 5:26 PM, Yan, Zheng <ukernel@gmail.com> wrote:
>>>>>
>>>>> I believe the bug you see is the result of the two timestamps
>>>>> currently being almost guaranteed to be different in the latest
>>>>> kernels.
>>>>> Changing r_stamp to use current_kernel_time() will make it the
>>>>> same value most of the time (as it was before Deepa's patch),
>>>>> but when the timer interrupt happens between the timestamps,
>>>>> the two are still different, it's just much harder to hit.
>>>>>
>>>>> I think the proper solution should be to change __ceph_setattr()
>>>>> in a way that has req->r_stamp always synchronized with i_ctime.
>>>>> If we copy i_ctime to r_stamp, that will also take care of the
>>>>> future issues with the planned changes to current_time().
>>>>>
>>>> I already have a patch
>>>> https://github.com/ceph/ceph-client/commit/24f54cd18e195a002ee3d2ab50dbc952fd9f82af
>>>
>>> Looks good to me. In case anyone cares:
>>> Acked-by: Arnd Bergmann <arnd@arndb.de>
>>>
>>>>> The part I don't understand is what else r_stamp (i.e. the time
>>>>> stamp in ceph_msg_data with type==
>>>>> CEPH_MSG_CLIENT_REQUEST) is used for, other than setting
>>>>> ctime in CEPH_MDS_OP_SETATTR.
>>>>>
>>>>> Will this be used to update the stored i_ctime for other operations
>>>>> too? If so, we would need to synchronize it with the in-memory
>>>>> i_ctime for all operations that do this.
>>>>>
>>>>
>>>> yes,  mds uses it to update ctime of modified inodes. For example,
>>>> when handling mkdir, mds set ctime of both parent inode and new inode
>>>> to r_stamp.
>>>
>>> I see, so we may have a variation of that problem there as well: From
>>> my reading of the code, the child inode is not in memory yet, so
>>> that seems fine, but I could not find where the parent in-memory inode
>>> i_ctime is updated in ceph, but it is most likely not the same as
>>> req->r_stamp (assuming it gets updated at all).
>>
>> i_ctime is updated when handling request reply, by ceph_fill_file_time().
>> __ceph_setattr() can update the in-memory inode's ctime after request
>> reply is received. The difference between ktime_get_real_ts() and
>> current_time() can be larger than round-trip time of request. So it's
>> still possible that __ceph_setattr() make ctime go back.
>
> But the __ceph_setattr() problem should be fixed by your patch, right?
>
> What I meant is another related problem in ceph_mkdir() where the
> i_ctime field of the parent inode is different between the persistent
> representation in the mds and the in-memory representation.
>

I don't see any problem in mkdir case. Parent inode's i_ctime in mds is set to
r_stamp. When client receives request reply, it set its in-memory inode's ctime
to the same time stamp.

Regards
Yan, Zheng

>     Arnd
>
>>> Would it make sense require all callers of ceph_mdsc_do_request()
>>> to update r_stamp at the same time as i_ctime to keep them in sync?
