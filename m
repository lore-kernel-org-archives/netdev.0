From: Chen Gang <gang.chen@asianux.com>
Subject: [Suggestion] net/atm :  for sprintf, need check the total write length
 whether larger than a page.
Date: Wed, 21 Nov 2012 12:29:48 +0800
Message-ID: <50AC58BC.1020004@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:42312 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026Ab2KUE2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 23:28:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David Miller:

in net/atm/atm_sysfs.c:
  suggest to check the write length whether larger than a page.
  the length of parameter buf is one page size (reference: fill_read_buffer at fs/sysfs/file.c)
  and the count of atm adresses are not limited (reference: atm_dev_ioctl -> atm_add_addr)

  thanks.

gchen.

 34 static ssize_t show_atmaddress(struct device *cdev,
 35                                struct device_attribute *attr, char *buf)
 36 {
 37         unsigned long flags;
 38         char *pos = buf;
 39         struct atm_dev *adev = to_atm_dev(cdev);
 40         struct atm_dev_addr *aaddr;
 41         int bin[] = { 1, 2, 10, 6, 1 }, *fmt = bin;
 42         int i, j;
 43 
 44         spin_lock_irqsave(&adev->lock, flags);
 45         list_for_each_entry(aaddr, &adev->local, entry) {
 46                 for (i = 0, j = 0; i < ATM_ESA_LEN; ++i, ++j) {
 47                         if (j == *fmt) {
 48                                 pos += sprintf(pos, ".");
 49                                 ++fmt;
 50                                 j = 0;
 51                         }
 52                         pos += sprintf(pos, "%02x",
 53                                        aaddr->addr.sas_addr.prv[i]);
 54                 }
 55                 pos += sprintf(pos, "\n");
 56         }
 57         spin_unlock_irqrestore(&adev->lock, flags);
 58 
 59         return pos - buf;
 60 }
 61 



in net/atm/addr.c

 67 int atm_add_addr(struct atm_dev *dev, const struct sockaddr_atmsvc *addr,
 68                  enum atm_addr_type_t atype)
 69 {
 70         unsigned long flags;
 71         struct atm_dev_addr *this;
 72         struct list_head *head;
 73         int error;
 74 
 75         error = check_addr(addr);
 76         if (error)
 77                 return error;
 78         spin_lock_irqsave(&dev->lock, flags);
 79         if (atype == ATM_ADDR_LECS)
 80                 head = &dev->lecs;
 81         else
 82                 head = &dev->local;
 83         list_for_each_entry(this, head, entry) {
 84                 if (identical(&this->addr, addr)) {
 85                         spin_unlock_irqrestore(&dev->lock, flags);
 86                         return -EEXIST;
 87                 }
 88         }
 89         this = kmalloc(sizeof(struct atm_dev_addr), GFP_ATOMIC);
 90         if (!this) {
 91                 spin_unlock_irqrestore(&dev->lock, flags);
 92                 return -ENOMEM;
 93         }
 94         this->addr = *addr;
 95         list_add(&this->entry, head);
 96         spin_unlock_irqrestore(&dev->lock, flags);
 97         if (head == &dev->local)
 98                 notify_sigd(dev);
 99         return 0;
100 }
101 


in net/atm/resources.c

195 int atm_dev_ioctl(unsigned int cmd, void __user *arg, int compat)
196 {
197         void __user *buf;
198         int error, len, number, size = 0;
199         struct atm_dev *dev;
200         struct list_head *p;
201         int *tmp_buf, *tmp_p;
202         int __user *sioc_len;
203         int __user *iobuf_len;
204 
205 #ifndef CONFIG_COMPAT
206         compat = 0; /* Just so the compiler _knows_ */
207 #endif
208 
209         switch (cmd) {
210         case ATM_GETNAMES:
211                 if (compat) {
212 #ifdef CONFIG_COMPAT
213                         struct compat_atm_iobuf __user *ciobuf = arg;
214                         compat_uptr_t cbuf;
215                         iobuf_len = &ciobuf->length;
216                         if (get_user(cbuf, &ciobuf->buffer))
217                                 return -EFAULT;
218                         buf = compat_ptr(cbuf);
219 #endif
220                 } else {
221                         struct atm_iobuf __user *iobuf = arg;
222                         iobuf_len = &iobuf->length;
223                         if (get_user(buf, &iobuf->buffer))
224                                 return -EFAULT;
225                 }
226                 if (get_user(len, iobuf_len))
227                         return -EFAULT;
228                 mutex_lock(&atm_dev_mutex);
229                 list_for_each(p, &atm_devs)
230                         size += sizeof(int);
231                 if (size > len) {
232                         mutex_unlock(&atm_dev_mutex);
233                         return -E2BIG;
234                 }
235                 tmp_buf = kmalloc(size, GFP_ATOMIC);
236                 if (!tmp_buf) {
237                         mutex_unlock(&atm_dev_mutex);
238                         return -ENOMEM;
239                 }
240                 tmp_p = tmp_buf;
241                 list_for_each(p, &atm_devs) {
242                         dev = list_entry(p, struct atm_dev, dev_list);
243                         *tmp_p++ = dev->number;
244                 }
245                 mutex_unlock(&atm_dev_mutex);
246                 error = ((copy_to_user(buf, tmp_buf, size)) ||
247                          put_user(size, iobuf_len))
248                         ? -EFAULT : 0;
249                 kfree(tmp_buf);
250                 return error;
251         default:
252                 break;
253         }
254 
255         if (compat) {
256 #ifdef CONFIG_COMPAT
257                 struct compat_atmif_sioc __user *csioc = arg;
258                 compat_uptr_t carg;
259 
260                 sioc_len = &csioc->length;
261                 if (get_user(carg, &csioc->arg))
262                         return -EFAULT;
263                 buf = compat_ptr(carg);
264 
265                 if (get_user(len, &csioc->length))
266                         return -EFAULT;
267                 if (get_user(number, &csioc->number))
268                         return -EFAULT;
269 #endif
270         } else {
271                 struct atmif_sioc __user *sioc = arg;
272 
273                 sioc_len = &sioc->length;
274                 if (get_user(buf, &sioc->arg))
275                         return -EFAULT;
276                 if (get_user(len, &sioc->length))
277                         return -EFAULT;
278                 if (get_user(number, &sioc->number))
279                         return -EFAULT;
280         }
281 
282         dev = try_then_request_module(atm_dev_lookup(number), "atm-device-%d",
283                                       number);
284         if (!dev)
285                 return -ENODEV;
286 
287         switch (cmd) {
288         case ATM_GETTYPE:
289                 size = strlen(dev->type) + 1;
290                 if (copy_to_user(buf, dev->type, size)) {
291                         error = -EFAULT;
292                         goto done;
293                 }
294                 break;
295         case ATM_GETESI:
296                 size = ESI_LEN;
297                 if (copy_to_user(buf, dev->esi, size)) {
298                         error = -EFAULT;
299                         goto done;
300                 }
301                 break;
302         case ATM_SETESI:
303         {
304                 int i;
305 
306                 for (i = 0; i < ESI_LEN; i++)
307                         if (dev->esi[i]) {
308                                 error = -EEXIST;
309                                 goto done;
310                         }
311         }
312         /* fall through */
313         case ATM_SETESIF:
314         {
315                 unsigned char esi[ESI_LEN];
316 
317                 if (!capable(CAP_NET_ADMIN)) {
318                         error = -EPERM;
319                         goto done;
320                 }
321                 if (copy_from_user(esi, buf, ESI_LEN)) {
322                         error = -EFAULT;
323                         goto done;
324                 }
325                 memcpy(dev->esi, esi, ESI_LEN);
326                 error =  ESI_LEN;
327                 goto done;
328         }
329         case ATM_GETSTATZ:
330                 if (!capable(CAP_NET_ADMIN)) {
331                         error = -EPERM;
332                         goto done;
333                 }
334                 /* fall through */
335         case ATM_GETSTAT:
336                 size = sizeof(struct atm_dev_stats);
337                 error = fetch_stats(dev, buf, cmd == ATM_GETSTATZ);
338                 if (error)
339                         goto done;
340                 break;
341         case ATM_GETCIRANGE:
342                 size = sizeof(struct atm_cirange);
343                 if (copy_to_user(buf, &dev->ci_range, size)) {
344                         error = -EFAULT;
345                         goto done;
346                 }
347                 break;
348         case ATM_GETLINKRATE:
349                 size = sizeof(int);
350                 if (copy_to_user(buf, &dev->link_rate, size)) {
351                         error = -EFAULT;
352                         goto done;
353                 }
354                 break;
355         case ATM_RSTADDR:
356                 if (!capable(CAP_NET_ADMIN)) {
357                         error = -EPERM;
358                         goto done;
359                 }
360                 atm_reset_addr(dev, ATM_ADDR_LOCAL);
361                 break;
362         case ATM_ADDADDR:
363         case ATM_DELADDR:
364         case ATM_ADDLECSADDR:
365         case ATM_DELLECSADDR:
366         {
367                 struct sockaddr_atmsvc addr;
368 
369                 if (!capable(CAP_NET_ADMIN)) {
370                         error = -EPERM;
371                         goto done;
372                 }
373 
374                 if (copy_from_user(&addr, buf, sizeof(addr))) {
375                         error = -EFAULT;
376                         goto done;
377                 }
378                 if (cmd == ATM_ADDADDR || cmd == ATM_ADDLECSADDR)
379                         error = atm_add_addr(dev, &addr,
380                                              (cmd == ATM_ADDADDR ?
381                                               ATM_ADDR_LOCAL : ATM_ADDR_LECS));
382                 else
383                         error = atm_del_addr(dev, &addr,
384                                              (cmd == ATM_DELADDR ?
385                                               ATM_ADDR_LOCAL : ATM_ADDR_LECS));
386                 goto done;
387         }
...         ...
...         ...
