From: "Yan, Zheng" <ukernel@gmail.com>
Subject: Re: [PATCH 04/12] fs: ceph: CURRENT_TIME with ktime_get_real_ts()
Date: Fri, 2 Jun 2017 08:35:51 +0800
Message-ID: <CAAM7YA=rdDSd_YFbDu1-mKoU8_hkBdPQ+jMc3jsUtfxo-Jm3GQ@mail.gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
 <1491613030-11599-5-git-send-email-deepa.kernel@gmail.com>
 <CAAM7YAmp=cZKqGHa8UqDnrQLCe+6TKx+7w9SDZv4cW5fr4dfvA@mail.gmail.com>
 <CAK8P3a1pCw1Oo-Wg70kH5L12pbtEzGDfaPZ8g6ErERJjvY8znQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yuchao0@huawei.com, "J. Bruce Fields" <bfields@fieldses.org>,
 Chris Mason <clm@fb.com>, linux-mtd <linux-mtd@lists.infradead.org>,
 Deepa Dinamani <deepa.kernel@gmail.com>, Evgeniy Dushistov <dushistov@mail.ru>,
 Jeff Layton <jlayton@poochiereds.net>, ceph-devel <ceph-devel@vger.kernel.org>,
 devel@driverdev.osuosl.org, linux-cifs@vger.kernel.org,
 Paul Moore <paul@paul-moore.com>, y2038 Mailman List <y2038@lists.linaro.org>,
 Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Drokin,
 Oleg" <oleg.drokin@intel.com>, John Stultz <john.stultz@linaro.org>,
 Al Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.com>,
 Jaegeuk Kim <jaegeuk@kernel.org>, Thomas Gleixner <tglx@linutronix.de>,
 "Dilger, Andreas" <andreas.dilger@intel.com>, Josef Bacik <jbacik@fb.com>,
 gregkh <gregkh@linuxfoundation.org>, samba-technical@lists.samba.org,
 Linux Kernel Mailing List
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CAK8P3a1pCw1Oo-Wg70kH5L12pbtEzGDfaPZ8g6ErERJjvY8znQ@mail.gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Thu, Jun 1, 2017 at 6:22 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Thu, Jun 1, 2017 at 11:56 AM, Yan, Zheng <ukernel@gmail.com> wrote:
>> On Sat, Apr 8, 2017 at 8:57 AM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
>
>>> diff --git a/drivers/block/rbd.c b/drivers/block/rbd.c
>>> index 517838b..77204da 100644
>>> --- a/drivers/block/rbd.c
>>> +++ b/drivers/block/rbd.c
>>> @@ -1922,7 +1922,7 @@ static void rbd_osd_req_format_write(struct rbd_obj_request *obj_request)
>>>  {
>>>         struct ceph_osd_request *osd_req = obj_request->osd_req;
>>>
>>> -       osd_req->r_mtime = CURRENT_TIME;
>>> +       ktime_get_real_ts(&osd_req->r_mtime);
>>>         osd_req->r_data_offset = obj_request->offset;
>>>  }
>>>
>>> diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
>>> index c681762..1d3fa90 100644
>>> --- a/fs/ceph/mds_client.c
>>> +++ b/fs/ceph/mds_client.c
>>> @@ -1666,6 +1666,7 @@ struct ceph_mds_request *
>>>  ceph_mdsc_create_request(struct ceph_mds_client *mdsc, int op, int mode)
>>>  {
>>>         struct ceph_mds_request *req = kzalloc(sizeof(*req), GFP_NOFS);
>>> +       struct timespec ts;
>>>
>>>         if (!req)
>>>                 return ERR_PTR(-ENOMEM);
>>> @@ -1684,7 +1685,8 @@ ceph_mdsc_create_request(struct ceph_mds_client *mdsc, int op, int mode)
>>>         init_completion(&req->r_safe_completion);
>>>         INIT_LIST_HEAD(&req->r_unsafe_item);
>>>
>>> -       req->r_stamp = current_fs_time(mdsc->fsc->sb);
>>> +       ktime_get_real_ts(&ts);
>>> +       req->r_stamp = timespec_trunc(ts, mdsc->fsc->sb->s_time_gran);
>>
>> This change causes our kernel_untar_tar test case to fail (inode's
>> ctime goes back). The reason is that there is time drift between the
>> time stamps got by  ktime_get_real_ts() and current_time(). We need to
>> revert this change until current_time() uses ktime_get_real_ts()
>> internally.
>
> Hmm, the change was not supposed to have a user-visible effect, so
> something has gone wrong, but I don't immediately see how it
> relates to what you observe.
>
> ktime_get_real_ts() and current_time() use the same time base, there
> is no drift, but there is a difference in resolution, as the latter uses
> the time stamp of the last jiffies update, which may be up to one jiffy
> (10ms) behind the exact time we put in the request stamps here.
>
It happens in following sequence of events

1. create a new file, the inode's ctime is set to ktime_get_real_ts()
2. chmod the new file, the inode's ctime is set to current_time().

Inode's ctime goes back when current_time() is behind ktime_get_real_ts().

Regards
Yan, Zheng

> Do you still see problems if you use current_kernel_time() instead of
> ktime_get_real_ts()?
>
>         Arnd
