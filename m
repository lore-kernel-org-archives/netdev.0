From: Chen Gang <gang.chen@asianux.com>
Subject: [Suggestion] drivers/isdn/divert: break looping, or memory leak by
 calling kmalloc again
Date: Mon, 01 Apr 2013 10:11:09 +0800
Message-ID: <5158ECBD.4050109@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: isdn@linux-pingi.de, Jiri Slaby <jslaby@suse.cz>,
	Jiri Kosina <jkosina@suse.cz>, tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:50423 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754589Ab3DACLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Mar 2013 22:11:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Maintainers:

in drivers/isdn/divert/isdn_divert.c:

  in 'for' looping (line 395..515)
    the 'cs' may call kmalloc again (line 453).

  it seems need break looping, when get valid 'cs' value (line 509)


  please help check, thanks.


gchen.


382 /*************************************************/
383 /* called from common module on an incoming call */
384 /*************************************************/
385 static int isdn_divert_icall(isdn_ctrl *ic)
386 {
387         int retval = 0;
388         unsigned long flags;
389         struct call_struc *cs = NULL;
390         struct deflect_struc *dv;
391         char *p, *p1;
392         u_char accept;
393 
394         /* first check the internal deflection table */
395         for (dv = table_head; dv; dv = dv->next) {
396                 /* scan table */
397                 if (((dv->rule.callopt == 1) && (ic->command == ISDN_STAT_ICALLW)) ||
398                     ((dv->rule.callopt == 2) && (ic->command == ISDN_STAT_ICALL)))
399                         continue; /* call option check */
400                 if (!(dv->rule.drvid & (1L << ic->driver)))
401                         continue; /* driver not matching */
402                 if ((dv->rule.si1) && (dv->rule.si1 != ic->parm.setup.si1))
403                         continue; /* si1 not matching */
404                 if ((dv->rule.si2) && (dv->rule.si2 != ic->parm.setup.si2))
405                         continue; /* si2 not matching */
406 
407                 p = dv->rule.my_msn;
408                 p1 = ic->parm.setup.eazmsn;
409                 accept = 0;
410                 while (*p) {
411                         /* complete compare */
412                         if (*p == '-') {
413                                 accept = 1; /* call accepted */
414                                 break;
415                         }
416                         if (*p++ != *p1++)
417                                 break; /* not accepted */
418                         if ((!*p) && (!*p1))
419                                 accept = 1;
420                 } /* complete compare */
421                 if (!accept) continue; /* not accepted */
422 
423                 if ((strcmp(dv->rule.caller, "0")) ||
424                     (ic->parm.setup.phone[0])) {
425                         p = dv->rule.caller;
426                         p1 = ic->parm.setup.phone;
427                         accept = 0;
428                         while (*p) {
429                                 /* complete compare */
430                                 if (*p == '-') {
431                                         accept = 1; /* call accepted */
432                                         break;
433                                 }
434                                 if (*p++ != *p1++)
435                                         break; /* not accepted */
436                                 if ((!*p) && (!*p1))
437                                         accept = 1;
438                         } /* complete compare */
439                         if (!accept) continue; /* not accepted */
440                 }
441 
442                 switch (dv->rule.action) {
443                 case DEFLECT_IGNORE:
444                         return (0);
445 
446                 case DEFLECT_ALERT:
447                 case DEFLECT_PROCEED:
448                 case DEFLECT_REPORT:
449                 case DEFLECT_REJECT:
450                         if (dv->rule.action == DEFLECT_PROCEED)
451                                 if ((!if_used) || ((!extern_wait_max) && (!dv->rule.waittime)))
452                                         return (0); /* no external deflection needed */
453                         if (!(cs = kmalloc(sizeof(struct call_struc), GFP_ATOMIC)))
454                                 return (0); /* no memory */
455                         init_timer(&cs->timer);
456                         cs->info[0] = '\0';
457                         cs->timer.function = deflect_timer_expire;
458                         cs->timer.data = (ulong) cs; /* pointer to own structure */
459 
460                         cs->ics = *ic; /* copy incoming data */
461                         if (!cs->ics.parm.setup.phone[0]) strcpy(cs->ics.parm.setup.phone, "0");
462                         if (!cs->ics.parm.setup.eazmsn[0]) strcpy(cs->ics.parm.setup.eazmsn, "0");
463                         cs->ics.parm.setup.screen = dv->rule.screen;
464                         if (dv->rule.waittime)
465                                 cs->timer.expires = jiffies + (HZ * dv->rule.waittime);
466                         else if (dv->rule.action == DEFLECT_PROCEED)
467                                 cs->timer.expires = jiffies + (HZ * extern_wait_max);
468                         else
469                                 cs->timer.expires = 0;
470                         cs->akt_state = dv->rule.action;
471                         spin_lock_irqsave(&divert_lock, flags);
472                         cs->divert_id = next_id++; /* new sequence number */
473                         spin_unlock_irqrestore(&divert_lock, flags);
474                         cs->prev = NULL;
475                         if (cs->akt_state == DEFLECT_ALERT) {
476                                 strcpy(cs->deflect_dest, dv->rule.to_nr);
477                                 if (!cs->timer.expires) {
478                                         strcpy(ic->parm.setup.eazmsn,
479                                                "Testtext direct");
480                                         ic->parm.setup.screen = dv->rule.screen;
481                                         strlcpy(ic->parm.setup.phone, dv->rule.to_nr, sizeof(ic->parm.setup.phone));
482                                         cs->akt_state = DEFLECT_AUTODEL; /* delete after timeout */
483                                         cs->timer.expires = jiffies + (HZ * AUTODEL_TIME);
484                                         retval = 5;
485                                 } else
486                                         retval = 1; /* alerting */
487                         } else {
488                                 cs->deflect_dest[0] = '\0';
489                                 retval = 4; /* only proceed */
490                         }
491                         sprintf(cs->info, "%d 0x%lx %s %s %s %s 0x%x 0x%x %d %d %s\n",
492                                 cs->akt_state,
493                                 cs->divert_id,
494                                 divert_if.drv_to_name(cs->ics.driver),
495                                 (ic->command == ISDN_STAT_ICALLW) ? "1" : "0",
496                                 cs->ics.parm.setup.phone,
497                                 cs->ics.parm.setup.eazmsn,
498                                 cs->ics.parm.setup.si1,
499                                 cs->ics.parm.setup.si2,
500                                 cs->ics.parm.setup.screen,
501                                 dv->rule.waittime,
502                                 cs->deflect_dest);
503                         if ((dv->rule.action == DEFLECT_REPORT) ||
504                             (dv->rule.action == DEFLECT_REJECT)) {
505                                 put_info_buffer(cs->info);
506                                 kfree(cs); /* remove */
507                                 return ((dv->rule.action == DEFLECT_REPORT) ? 0 : 2); /* nothing to do */
508                         }
509                         break;
510 
511                 default:
512                         return (0); /* ignore call */
513                 } /* switch action */
514                 break;
515         } /* scan_table */
516 
517         if (cs) {
518                 cs->prev = NULL;
519                 spin_lock_irqsave(&divert_lock, flags);
520                 cs->next = divert_head;
521                 divert_head = cs;
522                 if (cs->timer.expires) add_timer(&cs->timer);
523                 spin_unlock_irqrestore(&divert_lock, flags);
524 
525                 put_info_buffer(cs->info);
526                 return (retval);
527         } else
528                 return (0);
529 } /* isdn_divert_icall */
