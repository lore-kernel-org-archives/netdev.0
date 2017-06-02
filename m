From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH 04/12] fs: ceph: CURRENT_TIME with ktime_get_real_ts()
Date: Thu, 1 Jun 2017 17:36:56 -0700
Message-ID: <CALAqxLV-yVKWM5es7fAFiDzhSQmtZFiZDPQwBRUYbWUtqhoWVg@mail.gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
 <1491613030-11599-5-git-send-email-deepa.kernel@gmail.com>
 <CAAM7YAmp=cZKqGHa8UqDnrQLCe+6TKx+7w9SDZv4cW5fr4dfvA@mail.gmail.com>
 <CAK8P3a1pCw1Oo-Wg70kH5L12pbtEzGDfaPZ8g6ErERJjvY8znQ@mail.gmail.com> <CAAM7YAnWLUXMOCVbgfdKGfvK04EtAQcz-ETm7xFO=8Y=_fCvOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Arnd Bergmann <arnd@arndb.de>,
        Deepa Dinamani <deepa.kernel@gmail.com>,
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
        P
To: "Yan, Zheng" <ukernel@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CAAM7YAnWLUXMOCVbgfdKGfvK04EtAQcz-ETm7xFO=8Y=_fCvOQ@mail.gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 1, 2017 at 5:26 PM, Yan, Zheng <ukernel@gmail.com> wrote:
> On Thu, Jun 1, 2017 at 6:22 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> On Thu, Jun 1, 2017 at 11:56 AM, Yan, Zheng <ukernel@gmail.com> wrote:
>>> On Sat, Apr 8, 2017 at 8:57 AM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
>>
>>>> diff --git a/drivers/block/rbd.c b/drivers/block/rbd.c
>>>> index 517838b..77204da 100644
>>>> --- a/drivers/block/rbd.c
>>>> +++ b/drivers/block/rbd.c
>>>> @@ -1922,7 +1922,7 @@ static void rbd_osd_req_format_write(struct rbd_obj_request *obj_request)
>>>>  {
>>>>         struct ceph_osd_request *osd_req = obj_request->osd_req;
>>>>
>>>> -       osd_req->r_mtime = CURRENT_TIME;
>>>> +       ktime_get_real_ts(&osd_req->r_mtime);
>>>>         osd_req->r_data_offset = obj_request->offset;
>>>>  }
>>>>
>>>> diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
>>>> index c681762..1d3fa90 100644
>>>> --- a/fs/ceph/mds_client.c
>>>> +++ b/fs/ceph/mds_client.c
>>>> @@ -1666,6 +1666,7 @@ struct ceph_mds_request *
>>>>  ceph_mdsc_create_request(struct ceph_mds_client *mdsc, int op, int mode)
>>>>  {
>>>>         struct ceph_mds_request *req = kzalloc(sizeof(*req), GFP_NOFS);
>>>> +       struct timespec ts;
>>>>
>>>>         if (!req)
>>>>                 return ERR_PTR(-ENOMEM);
>>>> @@ -1684,7 +1685,8 @@ ceph_mdsc_create_request(struct ceph_mds_client *mdsc, int op, int mode)
>>>>         init_completion(&req->r_safe_completion);
>>>>         INIT_LIST_HEAD(&req->r_unsafe_item);
>>>>
>>>> -       req->r_stamp = current_fs_time(mdsc->fsc->sb);
>>>> +       ktime_get_real_ts(&ts);
>>>> +       req->r_stamp = timespec_trunc(ts, mdsc->fsc->sb->s_time_gran);
>>>
>>> This change causes our kernel_untar_tar test case to fail (inode's
>>> ctime goes back). The reason is that there is time drift between the
>>> time stamps got by  ktime_get_real_ts() and current_time(). We need to
>>> revert this change until current_time() uses ktime_get_real_ts()
>>> internally.
>>
>> Hmm, the change was not supposed to have a user-visible effect, so
>> something has gone wrong, but I don't immediately see how it
>> relates to what you observe.
>>
>> ktime_get_real_ts() and current_time() use the same time base, there
>> is no drift, but there is a difference in resolution, as the latter uses
>> the time stamp of the last jiffies update, which may be up to one jiffy
>> (10ms) behind the exact time we put in the request stamps here.
>>
>> Do you still see problems if you use current_kernel_time() instead of
>> ktime_get_real_ts()?
>
> The problem disappears after using current_kernel_time().
>
> https://github.com/ceph/ceph-client/commit/2e0f648da23167034a3cf1500bc90ec60aef2417

>From the commit above:
"It seems there is time drift between ktime_get_real_ts() and
current_kernel_time()"

Its more of a granularity difference. current_kernel_time() returns
the cached time at the last tick, where as ktime_get_real_ts() reads
the clocksource hardware and returns the immediate time.

Filesystems usually use the cached time (similar to
CLOCK_REALTIME_COARSE), for performance reasons, as touching the
clocksource takes time.

thanks
-john
